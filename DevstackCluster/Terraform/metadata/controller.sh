#!/bin/sh

prepare_basic() {
  apt-get update -qy
  apt-get upgrade -qy
  timedatectl set-timezone Europe/Moscow
  apt-get install -qy git nmap telnet openssl jq
}

prepare_conf() {
  MYSQL_PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  tee /opt/stack/devstack/local.conf > /dev/null <<EOF
[[local|localrc]]
# Controller node
HOST_IP=192.168.11.10 # РАБОТАЕТ, НО НУЖНО УДАЛИТЬ ДЕФОЛТНЫЙ МАРШРУТ (br-ex) И СОЗДАТЬ НОВЫЙ (eth0) + еще один для 10.0.0.0/22
SYSLOG_HOST=192.168.11.10
LOGFILE=\$DEST/logs/stack.sh.log
GIT_BASE=https://opendev.org

ADMIN_PASSWORD=${PASS}
DATABASE_PASSWORD=${MYSQL_PASS}
RABBIT_PASSWORD=${PASS}
SERVICE_PASSWORD=${PASS}S
SERVICE_TOKEN=${PASS}

## Neutron options
Q_USE_SECGROUP=True
FLOATING_RANGE="192.168.12.0/25"
IPV4_ADDRS_SAFE_TO_USE="10.12.0.0/22"
PUBLIC_NETWORK_GATEWAY="192.168.12.1"   # eth1
PUBLIC_INTERFACE=eth1
Q_FLOATING_ALLOCATION_POOL=start=192.168.12.80,end=192.168.12.89

# Open vSwitch provider networking configuration
Q_USE_PROVIDERNET_FOR_PUBLIC=True
OVS_PHYSICAL_BRIDGE=br-ex
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=public:br-ex

enable_service rabbit
enable_plugin neutron \$GIT_BASE/openstack/neutron

# Octavia supports using QoS policies on the VIP port:
enable_service q-qos
enable_service placement-api placement-client

# Octavia services
enable_plugin octavia \$GIT_BASE/openstack/octavia master
enable_plugin octavia-dashboard \$GIT_BASE/openstack/octavia-dashboard
enable_plugin ovn-octavia-provider \$GIT_BASE/openstack/ovn-octavia-provider
enable_plugin octavia-tempest-plugin \$GIT_BASE/openstack/octavia-tempest-plugin
enable_service octavia o-api o-cw o-hm o-hk o-da
# Tempest
enable_service tempest
EOF
}

prepare_devstack() {
  git clone https://opendev.org/openstack/devstack
  ./devstack/tools/create-stack-user.sh
  mv devstack /opt/stack
  chown -R stack:stack /opt/stack/devstack
  prepare_conf
  chown stack:stack /opt/stack/devstack/local.conf
  # su -u stack /opt/stack/devstack/stack.sh
}

prepare_basic

if prepare_devstack;
then
  echo "SUCCESS!"
else
  echo "FAILED!"
fi