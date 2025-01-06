#!/bin/bash

timedatectl set-timezone Europe/Moscow
dnf install -y nmap telnet openssl
tee -a /etc/hosts > /dev/null <<EOF

192.168.11.10 controller
192.168.11.20 cmp1
192.168.11.30 cmp2
192.168.11.40 grafana
EOF

dnf install -y golang-github-prometheus-node-exporter centos-release-openstack-zed
dnf install -y etcd
systemctl start prometheus-node-exporter.service

tee /etc/etcd/etcd.conf > /dev/null <<EOF
ETCD_NAME=$(hostname)
ETCD_LISTEN_PEER_URLS="http://$(ip -4 -br ad show dev eth0 | awk '{print $3}' | cut -d'/' -f1):2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$(hostname):2380"
ETCD_INITIAL_CLUSTER="controller=http://controller:2380,cmp1=http://cmp1:2380,cmp2=http://cmp2:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"
ETCD_LISTEN_CLIENT_URLS="http://localhost:2379"
ETCD_DATA_DIR="/var/lib/etcd/cluster.etcd"
EOF
systemctl start etcd

