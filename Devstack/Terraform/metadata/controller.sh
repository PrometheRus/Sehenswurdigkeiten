#!/bin/bash

prepare_basic() {
  apt-get update -qy
  apt-get upgrade -qy
  timedatectl set-timezone Europe/Moscow
  apt-get install -qy git nmap telnet openssl jq
}

prepare_hosts() {
  tee -a /etc/hosts /dev/null <<EOF
192.168.11.10 controller
192.168.11.11 cmp1
192.168.11.12 cmp2
EOF
}

prepare_etcd() {
  apt-get -qy install etcd-server etcd-client
  systemctl disable --now etcd

  mkdir -m 700 /var/lib/etcd@"$(hostname)" && chown -R etcd:etcd /var/lib/etcd@"$(hostname)"
  tee /etc/systemd/system/etcd\@.service > /dev/null <<EOF
[Unit]
Description=etcd - highly-available key value store  ('%I' instance)
Documentation=https://etcd.io/docs
Documentation=man:etcd
After=network.target
Wants=network-online.target

[Service]
Environment=DAEMON_ARGS=
Environment=ETCD_NAME=%H
Environment=ETCD_DATA_DIR=/var/lib/etcd@%i/default
EnvironmentFile=-/etc/default/etcd\@%i
Type=notify
User=etcd
PermissionsStartOnly=true
#ExecStart=/bin/sh -c "GOMAXPROCS=$(nproc) /usr/bin/etcd $DAEMON_ARGS"
ExecStart=/usr/bin/etcd $DAEMON_ARGS
Restart=on-abnormal
#RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
Alias=etcd@%i.service
EOF

  tee /etc/default/etcd@"$(hostname)" > /dev/null <<EOF
ETCD_NAME=$(hostname)
ETCD_LISTEN_PEER_URLS="http://$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1):12380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$(hostname):12380"
ETCD_INITIAL_CLUSTER="controller=http://controller:12380,cmp1=http://cmp1:12380,cmp2=http://cmp2:12380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:12379"
ETCD_LISTEN_CLIENT_URLS="http://localhost:12379"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_DATA_DIR="/var/lib/etcd@$(hostname)"
ETCD_ELECTION_TIMEOUT="5000"
ETCD_HEARTBEAT_INTERVAL="1000"
ETCD_INITIAL_ELECTION_TICK_ADVANCE="false"
ETCD_AUTO_COMPACTION_RETENTION="1"
EOF

  mkdir /etc/systemd/system/etcd@"$(hostname)".service.d
  tee /etc/systemd/system/etcd@"$(hostname)".service.d/override.conf <<EOF
[Service]
TimeoutSec=1800
EOF
  systemctl daemon-reload
  systemctl enable --now etcd@"$(hostname)"
  etcdctl --endpoints=127.0.0.1:12379 member list
}

prepare_keys() {
  MYSQL_PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  etcdctl --endpoints=127.0.0.1:12379 put MYSQL_PASS $MYSQL_PASS

  ADMIN_PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  etcdctl --endpoints=127.0.0.1:12379 put ADMIN_PASS $ADMIN_PASS
}

prepare_conf()  {
  tee /opt/stack/devstack/local.conf > /dev/null <<EOF
[[local|localrc]]
# Controller node
HOST_IP=$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)
GIT_BASE=https://opendev.org

### Logging
LOGFILE=/opt/stack/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=True

### Passwords
ADMIN_PASSWORD=${ADMIN_PASS}
DATABASE_PASSWORD=${MYSQL_PASS}
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
SERVICE_TOKEN=\$ADMIN_PASSWORD

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

# Cinder (optional)
# disable_service c-api c-vol c-sch

# Tempest
enable_service tempest
EOF
  chown stack:stack /opt/stack/devstack/local.conf
}

prepare_ssh() {
  mkdir -m 0700 /opt/stack/.ssh
  ssh-keygen -t ed25519 -C "Devstack" -f /opt/stack/.ssh/virt -q -N ""
  tee /opt/stack/.ssh/authorized_keys > /dev/null <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Qs3Wltt98Hx2A+dXIPFZEAgJ38afG9BOnxeeR41Bk
$(cat /opt/stack/.ssh/virt.pub)
EOF
  tee /opt/stack/.ssh/config > /dev/null <<EOF
Host *
 StrictHostKeyChecking no
 IdentityFile ~/.ssh/virt
 UserKnownHostsFile /dev/null
EOF
  chmod 600 /opt/stack/.ssh/config /opt/stack/.ssh/authorized_keys
  chown -R stack:stack /opt/stack/.ssh/

  # TODO - sending private key
}

prepare_devstack() {
  git clone https://opendev.org/openstack/devstack
  ./devstack/tools/create-stack-user.sh
  mv devstack /opt/stack
  chown -R stack:stack /opt/stack/devstack
  prepare_conf
  chown stack:stack /opt/stack/devstack/local.conf
  su -c "/opt/stack/devstack/stack.sh" --login stack
  prepare_ssh
  # ip route del default via 192.168.12.1
  # ip route add default via 192.168.11.1 dev eth0
}

prepare_basic
prepare_hosts
prepare_etcd
prepare_keys
prepare_devstack