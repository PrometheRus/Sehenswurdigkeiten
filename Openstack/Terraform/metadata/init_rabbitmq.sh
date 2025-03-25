#!/bin/bash

rm -fv /etc/yum.repos.d/epel-testing.repo

# Test: success

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
  dnf install -qy golang-github-prometheus-node-exporter centos-release-openstack-zed

  prepare_etcd

  systemctl enable --now prometheus-node-exporter.service
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

prepare_rabbit_password() {
  echo "START GENERATION RABBITMQ PASSWORD"
  RABBIT_PASS="$(openssl rand -hex 8)";
  etcdctl put RABBIT_PASS $RABBIT_PASS;
  etcdctl get RABBIT_PASS $RABBIT_PASS;
  echo "STOP GENERATION RABBITMQ PASSWORD"
}

prepare_rabbit() {
  echo "Start to prepare Rabbitmq-Server"
  tee /etc/yum.repos.d/rabbitmq.repo > /dev/null <<EOF
##
## Zero dependency Erlang RPM
##

[modern-erlang]
name=modern-erlang-el9
# Use a set of mirrors maintained by the RabbitMQ core team.
# The mirrors have significantly higher bandwidth quotas.
baseurl=https://yum1.rabbitmq.com/erlang/el/9/\$basearch
        https://yum2.rabbitmq.com/erlang/el/9/\$basearch
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[modern-erlang-noarch]
name=modern-erlang-el9-noarch
# Use a set of mirrors maintained by the RabbitMQ core team.
# The mirrors have significantly higher bandwidth quotas.
baseurl=https://yum1.rabbitmq.com/erlang/el/9/noarch
        https://yum2.rabbitmq.com/erlang/el/9/noarch
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[modern-erlang-source]
name=modern-erlang-el9-source
# Use a set of mirrors maintained by the RabbitMQ core team.
# The mirrors have significantly higher bandwidth quotas.
baseurl=https://yum1.rabbitmq.com/erlang/el/9/SRPMS
        https://yum2.rabbitmq.com/erlang/el/9/SRPMS
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1


##
## RabbitMQ Server
##

[rabbitmq-el9]
name=rabbitmq-el9
baseurl=https://yum2.rabbitmq.com/rabbitmq/el/9/\$basearch
        https://yum1.rabbitmq.com/rabbitmq/el/9/\$basearch
repo_gpgcheck=1
enabled=1
# Cloudsmith's repository key and RabbitMQ package signing key
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[rabbitmq-el9-noarch]
name=rabbitmq-el9-noarch
baseurl=https://yum2.rabbitmq.com/rabbitmq/el/9/noarch
        https://yum1.rabbitmq.com/rabbitmq/el/9/noarch
repo_gpgcheck=1
enabled=1
# Cloudsmith's repository key and RabbitMQ package signing key
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[rabbitmq-el9-source]
name=rabbitmq-el9-source
baseurl=https://yum2.rabbitmq.com/rabbitmq/el/9/SRPMS
        https://yum1.rabbitmq.com/rabbitmq/el/9/SRPMS
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
gpgcheck=0
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md
EOF
  dnf install -qy erlang logrotate rabbitmq-server
  systemctl enable --now rabbitmq-server
  rabbitmq-plugins enable rabbitmq_management
  rabbitmqctl add_user openstack "$(etcdctl get RABBIT_PASS --print-value-only)"
  rabbitmqctl set_user_tags openstack administrator
  rabbitmqctl add_vhost openstack
  rabbitmqctl set_permissions -p openstack openstack ".*" ".*" ".*"
  rabbitmqctl set_permissions -p / openstack ".*" ".*" ".*"
  rabbitmqctl enable_feature_flag all
  echo "Stopped to prepare Rabbitmq-Server"
}

prepare_basic
prepare_packages
prepare_rabbit_password
prepare_rabbit
