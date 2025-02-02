#!/bin/bash

common() {
  tee -a /etc/hosts > /dev/null <<EOF

192.168.199.71 grafana
192.168.199.72 prometheus
192.168.199.73 docker
EOF
  rm -f /etc/yum.repos.d/epel-testing.repo
}

prepare_prom() {
  dnf -yq update
  dnf -yq install golang-github-prometheus-node-exporter.x86_64 golang-github-prometheus
  tee -a /etc/default/prometheus-node-exporter > /dev/null << EOF

ARGS='--web.listen-address="192.168.199.72:9100"'
EOF

  tee  /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s
  external_labels:
      monitor: 'example'

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    scrape_timeout: 5s
    static_configs:
      - targets: ["localhost:9090"]


  - job_name: 'node'
    scrape_interval: 5s
    scrape_timeout: 5s
    static_configs:
      - targets: [prometheus:9100,grafana:9100,docker:9100]
EOF
  systemctl enable --now prometheus prometheus-node-exporter
}

common
prepare_prom