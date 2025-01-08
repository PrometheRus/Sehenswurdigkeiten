#!/bin/bash

prepare_basic() {
  timedatectl set-timezone Europe/Moscow
  dnf install -qy nmap telnet openssl
  tee -a /etc/hosts > /dev/null <<EOF

192.168.11.10 controller
192.168.11.20 cmp1
192.168.11.30 cmp2
192.168.11.40 grafana
192.168.11.41 srv
EOF
}

prepare_packages() {
  dnf install -qy dnf-plugins-core golang-github-prometheus-node-exporter centos-release-openstack-zed
  dnf config-manager --set-enabled crb
  systemctl start prometheus-node-exporter.service

  # Install Percona
  dnf -qy install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
  percona-release setup ps-80
  dnf -qy install percona-server-server

  # Install Keystone
  dnf install -qy openstack-keystone httpd python3-mod_wsgi

  # Install Neutron
  dnf install -qy openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch ebtables
  systemctl enable --now neutron-openvswitch-agent

  # Install Nova
  dnf -qy install openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler

  # Install Placement
  dnf -qy install openstack-placement-api

  # Install Openstack CLI
  dnf install -qy python3-openstackclient openstack-selinux

  # Update system packages
  # dnf update -qy
}

prepare_etcd() {
  dnf -qy install etcd
  tee /etc/etcd/etcd.conf > /dev/null <<EOF
ETCD_NAME=$(hostname)
ETCD_LISTEN_PEER_URLS="http://$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1):2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$(hostname):2380"
ETCD_INITIAL_CLUSTER="srv=http://srv:2380,controller=http://controller:2380,cmp1=http://cmp1:2380,cmp2=http://cmp2:2380,grafana=http://grafana:2380"
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
  systemctl start etcd
}

prepare_password () {
  MYSQL_PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  etcdctl put MYSQL_PASS $MYSQL_PASS

  ADMIN_PASS="$(openssl rand -hex 8)"
  etcdctl put ADMIN_PASS $ADMIN_PASS
  GLANCE_PASS="$(openssl rand -hex 8)";
  etcdctl put GLANCE_PASS $GLANCE_PASS;
  NEUTRON_PASS="$(openssl rand -base64 8)"
  etcdctl put NEUTRON_PASS $NEUTRON_PASS
  NOVA_PASS="$(openssl rand -hex 8)";
  etcdctl put NOVA_PASS $NOVA_PASS
  PLACEMENT_PASS="$(openssl rand -hex 8)";
  etcdctl put PLACEMENT_PASS $PLACEMENT_PASS
  METADATA_SECRET="$(openssl rand -hex 8)";
  etcdctl put METADATA_SECRET $METADATA_SECRET
  DEMO_USER_PASS="$(openssl rand -hex 8)";
  etcdctl put DEMO_USER_PASS $DEMO_USER_PASS;
  RABBIT_PASS="$(openssl rand -hex 8)";
  etcdctl put RABBIT_PASS $RABBIT_PASS;
}

prepare_percona() {
  # Change root's password
  systemctl stop mysqld; systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"; systemctl start mysqld
  mysql -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '$(etcdctl get MYSQL_PASS --print-value-only)';"
  systemctl stop mysqld; systemctl unset-environment MYSQLD_OPTS; systemctl start mysqld

  # Prepare databases and users
  MYSQL_PASS=$(etcdctl get MYSQL_PASS --print-value-only)

  tee /root/prepare.sql > /dev/null <<EOF
CREATE DATABASE IF NOT EXISTS keystone;
CREATE USER IF NOT EXISTS 'keystone'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%';

CREATE DATABASE IF NOT EXISTS neutron;
CREATE USER IF NOT EXISTS 'neutron'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%';

CREATE DATABASE IF NOT EXISTS octavia;
CREATE USER IF NOT EXISTS 'octavia'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON octavia.* TO 'octavia'@'%';

CREATE DATABASE IF NOT EXISTS glance;
CREATE USER IF NOT EXISTS 'glance'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%';

CREATE DATABASE IF NOT EXISTS nova;
CREATE DATABASE IF NOT EXISTS nova_api;
CREATE DATABASE IF NOT EXISTS nova_cell0;
CREATE USER IF NOT EXISTS 'nova'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%';

CREATE DATABASE IF NOT EXISTS placement;
CREATE USER IF NOT EXISTS 'placement'@'%' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%';
EOF
  chmod 600 /root/prepare.sql

  mysql --password="$(etcdctl get MYSQL_PASS --print-value-only)" -f < /root/prepare.sql
}

prepare_keystone() {
  tee /etc/keystone/keystone.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@srv:5672/openstack
use_journal = true

[database]
connection = mysql+pymysql://keystone:$(etcdctl get MYSQL_PASS --print-value-only)@controller/keystone

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
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@srv:5672/openstack
use_journal = true

[placement_database]
connection = mysql+pymysql://placement:$(etcdctl get MYSQL_PASS --print-value-only)@controller/placement

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
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@srv:5672/openstack
use_journal = true
enabled_apis = osapi_compute,metadata
my_ip = $(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)

[api_database]
connection = mysql+pymysql://nova:$(etcdctl get MYSQL_PASS --print-value-only)@controller/nova_api

[database]
connection = mysql+pymysql://nova:$(etcdctl get MYSQL_PASS --print-value-only)@controller/nova

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

prepare_neutron() {
  source /root/admin-openrc

  openstack user create --domain default --password "$(etcdctl get NEUTRON_PASS --print-value-only)" neutron
  # openstack project create service    - already created
  openstack role add --project service --user neutron admin
  openstack service create --name neutron --description "OpenStack Networking" network
  for val in public internal admin; do openstack endpoint create --region RegionOne network ${val} http://controller:9696; done
  ovs-vsctl add-br br-demo
  ovs-vsctl add-port br-demo eth1

  tee /etc/neutron/neutron.conf > /dev/null <<EOF
[DEFAULT]
core_plugin = ml2
service_plugins = router
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@srv:5672/openstack
use_journal = true
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true

[database]
connection = mysql+pymysql://neutron:$(etcdctl get MYSQL_PASS --print-value-only)@controller/neutron

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

  tee /etc/neutron/plugins/ml2/ml2_conf.ini > /dev/null <<EOF
[ml2]
type_drivers = flat,vlan,vxlan
tenant_network_types = vxlan
mechanism_drivers = openvswitch,l2population
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider
vni_ranges = 1:1000

EOF

  tee /etc/neutron/plugins/ml2/openvswitch_agent.ini > /dev/null <<EOF
[ovs]
bridge_mappings = provider:br-demo
local_ip = 192.168.12.10

[agent]
tunnel_types = vxlan
l2_population = true

[securitygroup]
enable_security_group = true
firewall_driver = openvswitch
#firewall_driver = iptables_hybrid # TODO

EOF

  tee /etc/neutron/l3_agent.ini > /dev/null <<EOF
[DEFAULT]
interface_driver = openvswitch

EOF

  tee /etc/neutron/dhcp_agent.ini > /dev/null <<EOF
interface_driver = openvswitch
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true

EOF

  tee /etc/neutron/metadata_agent.ini > /dev/null <<EOF
[DEFAULT]
nova_metadata_host = controller
metadata_proxy_shared_secret = $(etcdctl get METADATA_SECRET --print-value-only)

EOF

  tee -a /etc/nova/nova.conf > /dev/null <<EOF

[neutron]
auth_url = http://controller:5000
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = neutron
password = $(etcdctl get NEUTRON_PASS --print-value-only)
service_metadata_proxy = true
metadata_proxy_shared_secret = $(etcdctl get METADATA_SECRET --print-value-only)
EOF

  ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
  su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

    # Neutron
  systemctl enable --now neutron-server neutron-openvswitch-agent neutron-dhcp-agent neutron-metadata-agent

  # L3
  systemctl enable --now neutron-l3-agent.service
}

finish(){
  # After CMP1 & CMP2
  openstack compute service list --service nova-compute
  su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
}

prepare_basic
prepare_packages
prepare_etcd
prepare_password
prepare_percona
prepare_keystone
prepare_placement
prepare_nova
prepare_neutron
finish