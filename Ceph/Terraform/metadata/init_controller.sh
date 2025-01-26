#!/bin/bash

# ОСТАНОВИЛСЯ НА "Upload the amphora image"

prepare_basic() {
  timedatectl set-timezone Europe/Moscow
  dnf install -qy lvm2 centos-release-ceph-reef
  dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin cephadm
  usermod -aG docker "$(whoami)"

  cephadm add-repo --release reef
  cephadm install ceph-common

  tee -a /etc/hosts > /dev/null <<EOF

192.168.12.21 osd1
192.168.12.22 osd2
192.168.12.23 osd3
EOF
}

