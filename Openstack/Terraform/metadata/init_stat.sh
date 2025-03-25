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

  # Install Gnocchi
  dnf -qy install openstack-gnocchi-api openstack-gnocchi-metricd python3-gnocchiclient
  dnf -qy install uwsgi-plugin-common uwsgi-plugin-python3 uwsgi

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

prepare_ceilometer() {
  openstack user create --domain default --password "$(etcdctl get CEILOMETER_PASS --print-value-only)" ceilometer
  openstack role add --project service --user ceilometer admin
  openstack service create --name ceilometer --description "Telemetry" metering

  openstack user create --domain default --password "$(etcdctl get GNOCCI_PASS --print-value-only)" gnocchi
  openstack role add --project service --user gnocchi admin
  openstack service create --name gnocchi --description "Metric Service" metric

  for val in public internal admin; do openstack endpoint create --region RegionOne metric ${val} http://controller:8041; done
}

prepare_basic
prepare_packages
# prepare_ceilometer