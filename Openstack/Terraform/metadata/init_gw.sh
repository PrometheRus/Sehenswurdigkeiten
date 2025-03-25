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

  # Install Neutron-server
  dnf install -qy openstack-neutron

  # Install Neutron-ml2
  dnf install -qy openstack-neutron-ml2

  # Install openvswitch
  dnf install -qy openstack-neutron-openvswitch ebtables
  systemctl enable --now openvswitch

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

prerequisites_neutron() {
  ovs-vsctl add-br br-demo
  ovs-vsctl add-port br-demo eth1
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

}

prepare_modular_layer_2() {
  tee /etc/neutron/plugins/ml2/ml2_conf.ini > /dev/null <<EOF
[ml2]
type_drivers = flat,vlan,vxlan
tenant_network_types = vxlan,vlan
mechanism_drivers = openvswitch,l2population
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider
vni_ranges = 1:1000

[ml2_type_vxlan]

vni_ranges =10000:60000

[agent]
l2_population = True

# Добавил, так как, как будто, Openstack не читал файл из prepare_ovs_agent
[ovs]
integration_bridge = br-int
tunnel_bridge = br-tun
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
}

prepare_ovs_agent() {
  tee /etc/neutron/plugins/ml2/openvswitch_agent.ini > /dev/null <<EOF
[ovs]
integration_bridge = br-int
tunnel_bridge = br-tun
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
}

prepare_l3_agent() {
  tee /etc/neutron/l3_agent.ini > /dev/null <<EOF
[DEFAULT]
# interface_driver = openvswitch
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver

EOF
}

prepare_dhcp() {
  tee /etc/neutron/dhcp_agent.ini > /dev/null <<EOF
interface_driver = openvswitch
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true

dnsmasq_config_file =/etc/neutron/dnsmasq-neutron.conf

EOF

  tee /etc/neutron/dnsmasq-neutron.conf > /dev/null <<EOF
dhcp-option=6, 188.93.16.19, 188.93.17.19
log-facility = /var/log/neutron/dnsmasq.log
EOF

}

prepare_neutron_metadata() {
    tee /etc/neutron/metadata_agent.ini > /dev/null <<EOF
[DEFAULT]
nova_metadata_host = controller
metadata_proxy_shared_secret = $(etcdctl get METADATA_SECRET --print-value-only)

EOF
}

finalize() {
  ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

  su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

  # Server
  systemctl enable --now neutron-server

  # OVS
  systemctl enable --now neutron-openvswitch-agent

  # DHCP & Metadata
  systemctl enable --now neutron-dhcp-agent neutron-metadata-agent

  # L3
  systemctl enable --now neutron-l3-agent.service
}

prepare_basic
prepare_packages
prerequisites_neutron
prepare_neutron_server
prepare_modular_layer_2
prepare_ovs_agent
prepare_l3_agent
prepare_dhcp
prepare_neutron_metadata
finalize