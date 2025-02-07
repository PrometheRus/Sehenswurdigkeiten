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
  dnf install -qy dnf-plugins-core golang-github-prometheus-node-exporter centos-release-openstack-zed
  dnf config-manager --set-enabled crb

  prepare_etcd

  systemctl enable --now prometheus-node-exporter.service

  # Install Percona
  dnf -qy install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
  percona-release setup ps-80
  dnf -qy install percona-server-server

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

prepare_password () {
  MYSQL_PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  etcdctl put MYSQL_PASS $MYSQL_PASS
  ADMIN_PASS="$(openssl rand -hex 8)"
  GLANCE_PASS="$(openssl rand -hex 8)";
  NEUTRON_PASS="$(openssl rand -base64 8)"
  NOVA_PASS="$(openssl rand -hex 8)";
  PLACEMENT_PASS="$(openssl rand -hex 8)";
  OCTAVIA_PASS="$(openssl rand -hex 8)";
  METADATA_SECRET="$(openssl rand -hex 8)";
  DEMO_USER_PASS="$(openssl rand -hex 8)";


  etcdctl put ADMIN_PASS $ADMIN_PASS
  etcdctl put GLANCE_PASS $GLANCE_PASS;
  etcdctl put NEUTRON_PASS $NEUTRON_PASS
  etcdctl put NOVA_PASS $NOVA_PASS
  etcdctl put PLACEMENT_PASS $PLACEMENT_PASS
  etcdctl put OCTAVIA_PASS $OCTAVIA_PASS
  etcdctl put METADATA_SECRET $METADATA_SECRET
  etcdctl put DEMO_USER_PASS $DEMO_USER_PASS;
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

prepare_basic
prepare_packages
prepare_password
prepare_percona