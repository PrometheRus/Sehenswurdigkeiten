#!/bin/bash

# rsync -avhP ~/.ssh/virt root@"$(terraform output -raw osd1)":~/.ssh/

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

prepare_basic

setup_ceph() {
  cephadm bootstrap --log-to-file --cluster-network 192.168.12.0/25 --mon-ip 192.168.12.21

  # I don't know how to automatise it
  ssh-copy-id -f -i /etc/ceph/ceph.pub root@192.168.12.22
  ssh-copy-id -f -i /etc/ceph/ceph.pub root@192.168.12.23

  ceph orch host add osd2 192.168.12.22 --labels _admin
  ceph orch host add osd3 192.168.12.23 --labels _admin

  ceph orch daemon add osd host1:/dev/sdb
  ceph orch daemon add osd host2:/dev/sdb
  ceph orch daemon add osd host3:/dev/sdb
}


