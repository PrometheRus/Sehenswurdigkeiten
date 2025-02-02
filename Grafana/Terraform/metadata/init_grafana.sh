#!/bin/bash

common() {
  tee -a /etc/hosts > /dev/null <<EOF

192.168.199.71 grafana
192.168.199.72 prometheus
192.168.199.73 docker
EOF
  rm -f /etc/yum.repos.d/epel-testing.repo
}

prepare_grafana() {
  dnf -yq update
  dnf -yq install golang-github-prometheus-node-exporter.x86_64 grafana

    tee -a /etc/default/prometheus-node-exporter > /dev/null << EOF

ARGS='--web.listen-address="192.168.199.71:9100"'
EOF

  tee /etc/grafana/provisioning/datasources/grafana.yml > /dev/null <<EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
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
systemctl enable --now prometheus-node-exporter grafana-server
}

common
prepare_grafana