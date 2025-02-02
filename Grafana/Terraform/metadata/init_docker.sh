#!/bin/bash

common() {
  tee -a /etc/hosts > /dev/null <<EOF

192.168.199.71 grafana
192.168.199.72 prometheus
192.168.199.73 docker
EOF
  rm -f /etc/yum.repos.d/epel-testing.repo
}

prepare_docker() {
  dnf -yq update
  dnf -yq install golang-github-prometheus-node-exporter.x86_64 dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  dnf -yq install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  tee -a /etc/default/prometheus-node-exporter > /dev/null << EOF

ARGS='--web.listen-address="192.168.199.74:9100"'
EOF

  tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "metrics-addr": "172.17.0.1:9323"
}
EOF

  systemctl enable --now prometheus-node-exporter docker
}

prepare_docker_compose_web() {
  mkdir /root/web
  tee /root/web/back.conf > /dev/null <<EOF
server {
    listen 80;
    location / {
      return 200 "This is the nginx container with hostname: \$hostname and port: \$server_port\n";
    }
}
EOF

  tee /root/web/lb.conf > /dev/null <<EOF
upstream front {
  server nginx-back-1:80;  # Container 1 (TCP)
  server nginx-back-2:80;  # Container 2 (TCP)
  server nginx-back-3:80;  # Container 3 (TCP)
  server nginx-back-4:80;  # Container 3 (TCP)
  server nginx-back-5:80;  # Container 3 (TCP)
}

server {
  listen 8888;
  location / {
    add_header Content-Type text/plain;
    proxy_pass http://front;
  }
}
EOF

  tee /root/web/docker-compose-web.yml > /dev/null <<EOF
services:
  lb:
    image: nginx
    volumes:
      - /root/web/lb.conf:/etc/nginx/conf.d/lb.conf
    ports:
      - "8888:8888"
    depends_on:
      - back
    networks:
      - web
      - lb

  back:
    image: nginx
    restart: unless-stopped
    volumes:
      - /root/web/back.conf:/etc/nginx/conf.d/back.conf
    deploy:
      mode: replicated
      replicas: 5
    networks:
      - web

networks:
  lb:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "br@lb"
  web:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "br@web"
EOF
}

prepare_docker_compose_observability() {
  mkdir /root/observability

  tee /root/observability/web.conf > /dev/null <<EOF
server {
    listen 8881;
    location / {
      return 200 "This is the nginx container with hostname: \$hostname and port: \$server_port\n";
    }
}
EOF

  tee /root/observability/lb.conf > /dev/null <<EOF
upstream front {
  server observability-back-1:8881;  # Container 1 (TCP)
  server observability-back-2:8881;  # Container 2 (TCP)
  server observability-back-3:8881;  # Container 3 (TCP)
}

server {
  listen 8880;
  location / {
    add_header Content-Type text/plain;
    proxy_pass http://front;
  }
}
EOF

  tee /root/observability/grafana.yml > /dev/null <<EOF
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


  tee /root/observability/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'docker'
    static_configs:
      - targets: ['172.17.0.1:9323']

  - job_name: 'cadvisor'
    static_configs:
      - targets: [ '172.17.0.1:8080' ]
EOF

  tee /root/observability/docker-compose-observability.yml > /dev/null <<EOF
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - /root/observability/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    networks:
      - prometheus
      - cadvisor

  grafana:
    image: grafana/grafana
    volumes:
      - /root/observability/grafana.yml:/etc/grafana/provisioning/datasources/grafana.yml
    ports:
      - "3000:3000"
    networks:
      - grafana
      - prometheus


  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"
    networks:
      - cadvisor

  lb:
    image: nginx
    volumes:
      - /root/observability/lb.conf:/etc/nginx/conf.d/lb.conf
    ports:
      - "8880:8880"
    depends_on:
      - back
    networks:
      - obs-web

  back:
    image: nginx
    restart: unless-stopped
    volumes:
      - /root/observability/web.conf:/etc/nginx/conf.d/web.conf
    deploy:
      mode: replicated
      replicas: 3
    networks:
      - obs-web

networks:
  grafana:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "br@grafana"
  prometheus:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "br@prometheus"
  obs-web:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "br@obs-web"
  cadvisor:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "br@cadvisor"
EOF
}

common
prepare_docker
prepare_docker_compose_web
prepare_docker_compose_observability