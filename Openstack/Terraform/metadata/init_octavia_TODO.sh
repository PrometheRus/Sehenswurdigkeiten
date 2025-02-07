#!/bin/bash

rm -fv /etc/yum.repos.d/epel-testing.repo

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

  # Install Octavia
  dnf -qy install openstack-octavia-api openstack-octavia-health-manager openstack-octavia-housekeeping openstack-octavia-worker python3-octavia python3-octaviaclient

  # Install Octavia (building images)
  dnf -qy install qemu-kvm diskimage-builder kpartx

  # Install Openstack CLI
  dnf -qy install python3-openstackclient openstack-selinux

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

create_certificates_octavia() {
  git clone https://opendev.org/openstack/octavia.git
  cd octavia/bin/ || exit
  source create_dual_intermediate_CA.sh
  sudo mkdir -p /etc/octavia/certs/private
  sudo chmod 755 /etc/octavia -R
  sudo cp -p etc/octavia/certs/server_ca.cert.pem /etc/octavia/certs
  sudo cp -p etc/octavia/certs/server_ca-chain.cert.pem /etc/octavia/certs
  sudo cp -p etc/octavia/certs/server_ca.key.pem /etc/octavia/certs/private
  sudo cp -p etc/octavia/certs/client_ca.cert.pem /etc/octavia/certs
  sudo cp -p etc/octavia/certs/client.cert-and-key.pem /etc/octavia/certs/private
}

create_sg_octavia() { # TODO
  openstack security group create lb-mgmt-sec-grp
  openstack security group rule create --protocol icmp lb-mgmt-sec-grp
  openstack security group rule create --protocol tcp --dst-port 22 lb-mgmt-sec-grp
  openstack security group rule create --protocol tcp --dst-port 9443 lb-mgmt-sec-grp
  openstack security group create lb-health-mgr-sec-grp
  openstack security group rule create --protocol udp --dst-port 5555 lb-health-mgr-sec-grp
  openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey   # TODO
  sudo mkdir -m755 -p /etc/dhcp/octavia
  sudo cp octavia/etc/dhcp/dhclient.conf /etc/dhcp/octavia
}

prepare_octavia() {
  source /root/admin-openrc

  openstack user create --domain default --password "$(etcdctl get OCTAVIA_PASS --print-value-only)" octavia
  openstack role add --project service --user octavia admin
  openstack service create --name octavia --description "OpenStack Octavia" load-balancer
  for val in public internal admin; do openstack endpoint create --region RegionOne load-balancer ${val} http://controller:9876; done
  tee /root/octavia-openrc > /dev/null << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=service
export OS_USERNAME=octavia
export OS_PASSWORD=$(etcdctl get OCTAVIA_PASS --print-value-only)
export OS_AUTH_URL=http://controller:5000
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=3
EOF
  chmod 600 /root/octavia-openrc
  disk-image-create -a amd64 -o /root/ubuntu-amd64 vm ubuntu
  openstack image create --disk-format qcow2 --container-format bare --private --tag amphora --file /root/ubuntu-amd64.qcow2 amphora-x64-haproxy
  openstack flavor create --id 200 --vcpus 1 --ram 1024 --disk 2 "amphora" --private

  create_certificates_octavia
  # create_sg_octavia   # TODO
}