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

prepare_conf() {
  if [ "$(hostname)" == "cmp1" ];
    then OCTET="10";
    else OCTET="20";
  fi

  tee /opt/stack/devstack/local.conf > /dev/null <<EOF
[[local|localrc]]
# Compute Node
HOST_IP=$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1)
GIT_BASE=https://opendev.org

IPV4_ADDRS_SAFE_TO_USE="10.11.0.0/22"

Q_USE_SECGROUP=True
FLOATING_RANGE="192.168.12.0/25"
PUBLIC_NETWORK_GATEWAY="192.168.12.1"   # eth1
PUBLIC_INTERFACE=eth1
Q_FLOATING_ALLOCATION_POOL=start=192.168.12.${OCTET}0,end=192.168.12.${OCTET}9

LOGFILE=/opt/stack/logs/stack.sh.log

ADMIN_PASSWORD="$(etcdctl --endpoints=127.0.0.1:12379 get ADMIN_PASS --print-value-only)"
DATABASE_PASSWORD="$(etcdctl --endpoints=127.0.0.1:12379 get MYSQL_PASS --print-value-only)"
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD

DATABASE_TYPE=mysql
SERVICE_HOST=192.168.11.10 # change this - controller node
MYSQL_HOST=\$SERVICE_HOST
RABBIT_HOST=\$SERVICE_HOST
GLANCE_HOSTPORT=\$SERVICE_HOST:9292

ENABLED_SERVICES=n-cpu,c-vol,placement-client,ovn-controller,ovs-vswitchd,ovsdb-server,q-ovn-metadata-agent
NOVA_VNC_ENABLED=True
NOVNCPROXY_URL="http://\$SERVICE_HOST:6080/vnc_lite.html"
VNCSERVER_LISTEN=\$HOST_IP
VNCSERVER_PROXYCLIENT_ADDRESS=\$VNCSERVER_LISTEN

# Open vSwitch provider networking configuration
Q_USE_PROVIDERNET_FOR_PUBLIC=True
OVS_PHYSICAL_BRIDGE=br-ex
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=public:br-ex
EOF
  chown stack:stack /opt/stack/devstack/local.conf
}

prepare_ssh() {
  mkdir -m 0700 /opt/stack/.ssh
  tee /opt/stack/.ssh/authorized_keys > /dev/null <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Qs3Wltt98Hx2A+dXIPFZEAgJ38afG9BOnxeeR41Bk
EOF
  tee /opt/stack/.ssh/config > /dev/null <<EOF
Host *
 StrictHostKeyChecking no
 IdentityFile ~/.ssh/virt
 UserKnownHostsFile /dev/null
EOF
  chmod 600 /opt/stack/.ssh/config /opt/stack/.ssh/authorized_keys
  chown -R stack:stack /opt/stack/.ssh/
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

sleep 2100s;
prepare_devstack