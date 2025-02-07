#!/bin/bash

rm -fv /etc/yum.repos.d/epel-testing.repo

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
  dnf install -qy golang-github-prometheus-node-exporter centos-release-openstack-zed libvirt

  prepare_etcd

  systemctl enable --now prometheus-node-exporter.service

  # Install Neutron OVS
  dnf install -qy openstack-neutron-openvswitch
  systemctl enable --now openvswitch

  # Install Nova
  dnf install -qy openstack-nova-compute
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

prepare_nova () {
  tee /etc/nova/nova.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@rabbitmq:5672/openstack
enabled_apis = osapi_compute,metadata
use_journal = true
my_ip = $(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)
compute_driver=libvirt.LibvirtDriver

[libvirt]
virt_type = kvm

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
server_listen = 0.0.0.0
server_proxyclient_address = $(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)
novncproxy_base_url = http://controller:6080/vnc_auto.html

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

# Configure the Compute service to use the Networking service
[neutron]
auth_url = http://controller:5000
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = neutron
password = $(etcdctl get NEUTRON_PASS --print-value-only)

EOF
  systemctl enable --now libvirtd.service openstack-nova-compute.service
}

prepare_neutron_common() {
  # https://docs.openstack.org/neutron/latest/install/compute-install-option2-rdo.html
  tee /etc/neutron/neutron.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$(etcdctl get RABBIT_PASS --print-value-only)@rabbitmq:5672/openstack
use_journal = true

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

EOF
}

prepare_neutron_ovs() {
  ovs-vsctl add-br br-demo
  ovs-vsctl add-port br-demo eth1

  tee /etc/neutron/plugins/ml2/openvswitch_agent.ini > /dev/null <<EOF
[ovs]
bridge_mappings = provider:br-demo
local_ip = $(ip -4 -br ad show dev eth1 | awk '{print $3}' | cut -d'/' -f1)

[agent]
tunnel_types = vxlan
l2_population = true

[securitygroup]
enable_security_group = true
firewall_driver = openvswitch
#firewall_driver = iptables_hybrid # TODO

EOF
  systemctl enable --now neutron-openvswitch-agent
}

prepare_nova_network() {
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
EOF
  systemctl restart openstack-nova-compute.service
}

prepare_basic
prepare_packages
# Ждать, пока поднимется rabbitmq. В будущем можно заменить на проверку курлом
sleep 400s;
prepare_nova
prepare_neutron_common
prepare_neutron_ovs
prepare_nova_network