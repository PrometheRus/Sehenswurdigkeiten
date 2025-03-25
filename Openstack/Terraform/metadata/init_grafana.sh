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
  dnf install -qy golang-github-prometheus-node-exporter golang-github-prometheus grafana centos-release-openstack-zed
  prepare_etcd
}

prepare_prometheus() {
  tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
scrape_configs:
  - job_name: 'node'

    scrape_interval: 5s
    scrape_timeout: 5s
    static_configs:
      - targets: [controller:9100,cmp1:9100,cmp2:9100,grafana:9100,mysql:9100,stat:9100,rabbitmq:9100]
EOF

  tee /etc/grafana/provisioning/datasources/grafana.yml > /dev/null <<EOF
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    jsonData:
      httpMethod: POST
      manageAlerts: true
      prometheusType: Prometheus
      cacheLevel: 'High'
      disableRecordingRules: false
      incrementalQueryOverlapWindow: 10m
      exemplarTraceIdDestinations:
        - datasourceUid: my_jaeger_uid
          name: traceID
EOF

  systemctl enable --now prometheus grafana-server prometheus-node-exporter
  systemctl restart prometheus grafana-server prometheus-node-exporter
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

prepare_basic
prepare_packages
prepare_prometheus