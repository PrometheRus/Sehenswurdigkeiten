#!/bin/bash

prepare_basic() {
  timedatectl set-timezone Europe/Moscow
  yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
  percona-release setup pxc-80
  yum update -y && yum install -y percona-xtradb-cluster centos-release-openstack-zed

  tee -a /etc/hosts >> /dev/null <<EOF
192.168.10.11 server1
192.168.10.12 server2
192.168.10.13 server3
EOF
}

prepare_etcd() {
  dnf install -y etcd
  tee /etc/etcd/etcd.conf > /dev/null <<EOF
ETCD_NAME=$(hostname)
ETCD_LISTEN_PEER_URLS="http://$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1):2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$(hostname):2380"
ETCD_INITIAL_CLUSTER="server1=http://server1:2380,server2=http://server2:2380,server3=http://server3:2380"
ETCD_INITIAL_CLUSTER_TOKEN="percona-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"
ETCD_LISTEN_CLIENT_URLS="http://localhost:2379"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_DATA_DIR="/var/lib/etcd/$(hostname)"
ETCD_ELECTION_TIMEOUT="5000"
ETCD_HEARTBEAT_INTERVAL="1000"
ETCD_INITIAL_ELECTION_TICK_ADVANCE="false"
ETCD_AUTO_COMPACTION_RETENTION="1"
EOF
  systemctl enable --now etcd
}

prepare_mysql_password() {
  # Get current root password
  systemctl start mysql
  mysql_password=$(grep 'temporary password' /var/log/mysqld.log | grep -oP ".{12}$")

  tee /root/.my.cnf > /dev/null <<EOF
[client]
user=root
password=${mysql_password}
host=localhost
port=3306
EOF
  chmod 600 /root/.my.cnf

  # Set new password for root
  MYSQL_PASS="$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)!"
  etcdctl put MYSQL_PASS $MYSQL_PASS
  mysql --defaults-file=/root/.my.cnf --connect-expired-password  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$(etcdctl get MYSQL_PASS --print-value-only)';"
}

prepare_my.cnf() {
  tee /root/.my.cnf > /dev/null <<EOF
[client]
user=root
password=$(etcdctl get MYSQL_PASS --print-value-only)
host=localhost
port=3306
EOF
}

prepare_mysql_config() {
  systemctl stop mysql

  ### wsrep_provider=/usr/lib64/galera4/libgalera_smm.so    # уже есть с конфиге, дополнительно не нужно добавлять
  sed -i "s/wsrep_cluster_name=pxc-cluster/wsrep_cluster_name=demo/" /etc/my.cnf
  sed -i "s/wsrep_cluster_address=gcomm:\/\//wsrep_cluster_address=gcomm:\/\/192.168.10.11,192.168.10.12,192.168.10.13/" /etc/my.cnf
  sed -i "s/wsrep_node_name=pxc-cluster-node-1/wsrep_node_name=$(hostnamectl hostname)/" /etc/my.cnf
  sed -i "s/#wsrep_node_address=192.168.70.63/wsrep_node_address=$(hostname -I)/" /etc/my.cnf

  grep -ni -e wsrep_cluster_name -e wsrep_cluster_address -e wsrep_node_name -e wsrep_node_address /etc/my.cnf

  tee -a /etc/my.cnf > /dev/null <<EOF
pxc-encrypt-cluster-traffic=OFF
EOF
}

start() {
  if [ "$(hostname)" = "server1" ];
    then systemctl start mysql@bootstrap.service;
    else sleep 30s; systemctl start mysql;
  fi
}

prepare_basic
prepare_etcd
prepare_mysql_password
prepare_mysql_config
start
