#!/bin/bash

timedatectl set-timezone Europe/Moscow
tee -a /etc/hosts > /dev/null <<EOF

192.168.11.10 controller
192.168.11.20 cmp1
192.168.11.30 cmp2
192.168.11.40 grafana
EOF

dnf install -y golang-github-prometheus-node-exporter golang-github-prometheus grafana
systemctl start prometheus-node-exporter.service

# Prometheus Config
tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
scrape_configs:
  - job_name: 'node'

    scrape_interval: 5s
    scrape_timeout: 5s
    static_configs:
      - targets: [controller:9100,cmp1:9100,cmp2:9100, grafana:9100]
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

systemctl restart prometheus grafana-server prometheus-node-exporter