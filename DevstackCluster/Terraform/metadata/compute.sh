#!/bin/bash

prepare_basic() {
  timedatectl set-timezone Europe/Moscow
  apt-get install -qy git nmap telnet openssl jq
}

prepare_devstack() {
  git clone https://opendev.org/openstack/devstac
  ./devstack/tools/create-stack-user.sh
  mv devstack /opt/stack
  chown -R stack:stack /opt/stack/devstack
}

prepare_conf() {
  echo "TODO()"

  tee > /dev/null <<EOF
[[local|localrc]]
# Compute Node
# eth0
HOST_IP=192.168.11.10 # change this per compute node
GIT_BASE=https://opendev.org

IPV4_ADDRS_SAFE_TO_USE="10.11.0.0/22"

Q_USE_SECGROUP=True
FLOATING_RANGE="192.168.12.0/25"
PUBLIC_NETWORK_GATEWAY="192.168.12.1"   # eth1
PUBLIC_INTERFACE=eth1
Q_FLOATING_ALLOCATION_POOL=start=192.168.12.60,end=192.168.12.69

LOGFILE=$DEST/logs/stack.sh.log

ADMIN_PASSWORD=password
DATABASE_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password

DATABASE_TYPE=mysql
SERVICE_HOST=192.168.11.20 # change this - controller node
MYSQL_HOST=$SERVICE_HOST
RABBIT_HOST=$SERVICE_HOST
GLANCE_HOSTPORT=$SERVICE_HOST:9292

ENABLED_SERVICES=n-cpu,c-vol,placement-client,ovn-controller,ovs-vswitchd,ovsdb-server,q-ovn-metadata-agent
NOVA_VNC_ENABLED=True
NOVNCPROXY_URL="http://$SERVICE_HOST:6080/vnc_lite.html"
VNCSERVER_LISTEN=$HOST_IP
VNCSERVER_PROXYCLIENT_ADDRESS=$VNCSERVER_LISTEN

# Open vSwitch provider networking configuration
Q_USE_PROVIDERNET_FOR_PUBLIC=True
OVS_PHYSICAL_BRIDGE=br-ex
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=public:br-ex
EOF

}

prepare_basic
prepare_devstack