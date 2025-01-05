#!/bin/bash

timedatectl set-timezone Europe/Moscow
tee -a /etc/hosts > /dev/null <<EOF

192.168.11.10 controller
192.168.11.20 cmp1
192.168.11.30 cmp2
192.168.11.40 grafana
EOF

dnf install -y golang-github-prometheus-node-exporter
systemctl start prometheus-node-exporter.service