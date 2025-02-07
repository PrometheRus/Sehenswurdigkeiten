#!/bin/bash

prepare_basic() {
  timedatectl set-timezone Europe/Moscow
  # dnf install -qy nmap telnet openssl
  tee -a /etc/hosts > /dev/null <<EOF

192.168.11.30 controller
192.168.11.31 cmp1
192.168.11.32 cmp2
192.168.11.33 grafana
192.168.11.34 rabbitmq
192.168.11.35 stat
192.168.11.36 mysql
192.168.11.37 gw
EOF
}

prepare_packages() {
  dnf install -qy dnf-plugins-core golang-github-prometheus-node-exporter centos-release-openstack-zed
  dnf config-manager --set-enabled crb

  prepare_etcd

  systemctl enable --now prometheus-node-exporter.service

  # Install Keystone
  dnf install -qy openstack-keystone httpd python3-mod_wsgi

  # Install Nova
  dnf -qy install openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler

  # Install Neutron-server
  dnf install -qy openstack-neutron

  # Install ml2
  dnf install -qy openstack-neutron-ml2

  # Install Placement
  dnf -qy install openstack-placement-api

  # Install Glance
  dnf -qy install openstack-glance

  # Install Openstack CLI
  dnf -qy install python3-openstackclient openstack-selinux

  # Update system packages
  dnf update -qy
}

prepare_etcd() {
  dnf -qy install etcd

  tee /etc/etcd/etcd.conf > /dev/null <<EOF
ETCD_NAME=$(hostname)
ETCD_LISTEN_PEER_URLS="http://$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1):2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$(hostname):2380"
ETCD_INITIAL_CLUSTER="mysql=http://mysql:2380,rabbitmq=http://rabbitmq:2380,controller=http://controller:2380,cmp1=http://cmp1:2380,cmp2=http://cmp2:2380,grafana=http://grafana:2380,stat=http://stat:2380,gw=http://gw:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"
ETCD_LISTEN_CLIENT_URLS="http://localhost:2379"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_ELECTION_TIMEOUT="5000"
ETCD_HEARTBEAT_INTERVAL="1000"
ETCD_INITIAL_ELECTION_TICK_ADVANCE="false"
ETCD_AUTO_COMPACTION_RETENTION="1"
EOF

  mkdir -p /etc/systemd/system/etcd.service.d
  tee /etc/systemd/system/etcd.service.d/override.conf <<EOF
[Service]
TimeoutSec=1800
EOF
  systemctl daemon-reload
  systemctl enable --now etcd
}

prepare_keystone() {
  tee /etc/keystone/keystone.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@rabbitmq:5672/openstack
use_journal = true

[database]
connection = mysql+pymysql://keystone:$(etcdctl get MYSQL_PASS --print-value-only)@mysql/keystone

[token]
provider = fernet
EOF

  su -s /bin/sh -c "keystone-manage db_sync" keystone
  keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
  keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
  keystone-manage bootstrap --bootstrap-password "$(etcdctl get ADMIN_PASS --print-value-only)" \
    --bootstrap-admin-url http://controller:5000/v3/ \
    --bootstrap-internal-url http://controller:5000/v3/ \
    --bootstrap-public-url http://controller:5000/v3/ \
    --bootstrap-region-id RegionOne


  # Apache
  sed -i 's/#ServerName www.example.com:80/ServerName controller/' /etc/httpd/conf/httpd.conf
  ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
  systemctl enable httpd.service; systemctl start httpd.service

  tee > /root/admin-openrc /dev/null <<EOF
export OS_USERNAME=admin
export OS_PASSWORD="$(etcdctl get ADMIN_PASS --print-value-only)"
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF

  chmod 600 /root/admin-openrc
  source /root/admin-openrc

  openstack domain create --description "Demo Domain" demo
  openstack project create --domain default --description "Service Project" service
  openstack project create --domain default --description "Demo Project" demo
  openstack user create --domain default --password "$(etcdctl get DEMO_USER_PASS)" demo_user
  openstack role create demo_role
  openstack role add --project demo --user demo_user demo_role
  openstack user list
  openstack project list
}

prepare_placement() {
  source /root/admin-openrc

  openstack user create --domain default --password "$(etcdctl get PLACEMENT_PASS --print-value-only)" placement
  openstack role add --project service --user placement admin
  openstack service create --name placement --description "Placement API" placement
  for val in public internal admin; do openstack endpoint create --region RegionOne placement ${val} http://controller:8778; done

    # Configure Placement
  tee /etc/placement/placement.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@rabbitmq:5672/openstack
use_journal = true

[placement_database]
connection = mysql+pymysql://placement:$(etcdctl get MYSQL_PASS --print-value-only)@mysql/placement

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_url = http://controller:5000/v3
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = placement
password = $(etcdctl get PLACEMENT_PASS --print-value-only)
EOF

  # Решение проблемы с Placement (https://storyboard.openstack.org/#!/story/2006905)
  tee /etc/httpd/conf.d/00-placement-api.conf> /dev/null <<EOF
Listen 8778

<VirtualHost *:8778>
  WSGIProcessGroup placement-api
  WSGIApplicationGroup %{GLOBAL}
  WSGIPassAuthorization On
  WSGIDaemonProcess placement-api processes=3 threads=1 user=placement group=placement
  WSGIScriptAlias / /usr/bin/placement-api
  <IfVersion >= 2.4>
    ErrorLogFormat "%M"
  </IfVersion>
  ErrorLog /var/log/placement/placement-api.log
  #SSLEngine On
  #SSLCertificateFile ...
  #SSLCertificateKeyFile ...
  <Directory /usr/bin>
    Require all denied
    <Files "placement-api">
      <RequireAll>
        Require all granted
        Require not env blockAccess
      </RequireAll>
    </Files>
  </Directory>
</VirtualHost>

Alias /placement-api /usr/bin/placement-api
<Location /placement-api>
  SetHandler wsgi-script
  Options +ExecCGI
  WSGIProcessGroup placement-api
  WSGIApplicationGroup %{GLOBAL}
  WSGIPassAuthorization On
</Location>
EOF

  su -s /bin/sh -c "placement-manage db sync" placement
  systemctl restart httpd
}

prepare_nova() {
  source /root/admin-openrc

  openstack user create --domain default --password "$(etcdctl get NOVA_PASS --print-value-only)" nova
  openstack role add --project service --user nova admin
  openstack service create --name nova --description "OpenStack Compute" compute
  for val in public internal admin; do openstack endpoint create --region RegionOne compute ${val} http://controller:8774/v2.1; done

    # Configure Nova
  tee /etc/nova/nova.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@rabbitmq:5672/openstack
use_journal = true
enabled_apis = osapi_compute,metadata
my_ip = $(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)

[api_database]
connection = mysql+pymysql://nova:$(etcdctl get MYSQL_PASS --print-value-only)@mysql/nova_api

[database]
connection = mysql+pymysql://nova:$(etcdctl get MYSQL_PASS --print-value-only)@mysql/nova

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://controller:5000/
auth_url = http://controller:5000/
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = $(etcdctl get NOVA_PASS --print-value-only)

[service_user]
send_service_user_token = true
auth_url = https://controller/identity
auth_strategy = keystone
auth_type = password
project_domain_name = Default
project_name = service
user_domain_name = Default
username = nova
password = $(etcdctl get NOVA_PASS --print-value-only)

[vnc]
enabled = true
server_listen = $(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)
server_proxyclient_address = $(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)

[glance]
api_servers = http://controller:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:5000/v3
username = placement
password = $(etcdctl get PLACEMENT_PASS --print-value-only)

EOF

  su -s /bin/sh -c "nova-manage api_db sync" nova
  su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
  su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
  su -s /bin/sh -c "nova-manage db sync" nova
  su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

  systemctl enable --now openstack-nova-api openstack-nova-scheduler openstack-nova-conductor openstack-nova-novncproxy
}

prerequisites_neutron() {
  source /root/admin-openrc

  openstack user create --domain default --password "$(etcdctl get NEUTRON_PASS --print-value-only)" neutron
  # openstack project create service    - already created
  openstack role add --project service --user neutron admin
  openstack service create --name neutron --description "OpenStack Networking" network
  for val in public internal admin; do openstack endpoint create --region RegionOne network ${val} http://controller:9696; done
}

prepare_neutron_server() {
  tee /etc/neutron/neutron.conf > /dev/null <<EOF
[DEFAULT]
core_plugin = ml2
service_plugins = router
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@rabbitmq:5672/openstack
use_journal = true
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true

[database]
connection = mysql+pymysql://neutron:$(etcdctl get MYSQL_PASS --print-value-only)@mysql/neutron

[keystone_authtoken]
www_authenticate_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = $(etcdctl get NEUTRON_PASS --print-value-only)

[nova]
auth_url = http://controller:5000
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = nova
password = $(etcdctl get NOVA_PASS --print-value-only)

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

EOF
  ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

  systemctl enable --now neutron-server
}

discover_hosts() {
  # After CMP1 & CMP2
  su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
  openstack compute service list --service nova-compute
}

prepare_glance() {
  openstack user create --domain default --password "$(etcdctl get GLANCE_PASS --print-value-only)" glance
  openstack role add --project service --user glance admin
  openstack service create --name glance --description "OpenStack Image" image
  for val in public internal admin; do openstack endpoint create --region RegionOne image ${val} http://controller:9292; done

  # Register quota limits (optional) (TODO)

  tee /etc/glance/glance-api.conf > /dev/null <<EOF
[database]
# use_keystone_limits = True    (optional)
connection = mysql+pymysql://glance:$(etcdctl get MYSQL_PASS --print-value-only)@mysql/glance
enabled_backends=fs:file

[keystone_authtoken]
www_authenticate_uri  = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = "$(etcdctl get GLANCE_PASS --print-value-only)"

[paste_deploy]
flavor = keystone

[glance_store]
default_backend = fs

[fs]
filesystem_store_datadir = /var/lib/glance/images/

[oslo_limit]
auth_url = http://controller:5000
auth_type = password
user_domain_id = default
username = glance
password = "$(etcdctl get GLANCE_PASS --print-value-only)"
system_scope = all
endpoint_id = $(openstack endpoint list --service glance --region RegionOne --interface public -c ID -f value)
region_name = RegionOne
EOF

  openstack role add --user glance --user-domain Default --system all reader
  su -s /bin/sh -c "glance-manage db_sync" glance
  systemctl enable --now openstack-glance-api.service

  wget -O /root/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2
  openstack image create --file /root/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2 --disk-format qcow2 --container-format bare --public 'Alma Linux 9 64-bit'
}

prepare_basic
prepare_packages
prepare_keystone
prepare_placement
prepare_nova
prerequisites_neutron
prepare_neutron_server
discover_hosts
prepare_glance