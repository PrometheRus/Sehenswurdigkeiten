#!/bin/bash

basic() {
  timedatectl set-timezone Europe/Moscow

  tee -a /etc/hosts > /dev/null <<EOF
<ip> k8master
<ip> k8node1
<ip> k8node2
EOF

  tee -a /etc/sudoers.d/vmuser > /dev/null <<EOF
vmuser ALL=(ALL) NOPASSWD:ALL
EOF

}

swap_off(){
  swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  systemctl mask dev-zram0.swap
}

kernel(){
  tee /etc/sysctl.d/99-kubernetes-cri.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
  sysctl --system

  tee /etc/modules-load.d/containerd.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

  modprobe overlay
  modprobe br_netfilter
  lsmod | egrep "br_netfilter|overlay"
}

selinix() {
  setenforce 0
  sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
}

packages() {
  dnf --setopt=disable_excludes=kubernetes install -y socat iproute-tc containerd kubelet kubeadm kubectl
}

containerd() {
  command containerd config default > /etc/containerd/config.toml
}

systemd() {
  systemctl enable --now containerd kubelet
}

init_kube() {
  kubeadm config images pull
  kubeadm init

  mkdir -p /home/vmuser/.kube
  cp -i /etc/kubernetes/admin.conf /home/vmuser/.kube/config
  chown vmuser:vmuser /home/vmuser/.kube/config

  runuser -l vmuser -c 'kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml'
  runuser -l vmuser -c 'kubectl get pod -n kube-system'
}

basic
swap_off
kernel
selinix
packages
containerd
systemd

if [ "$(hostname)" == "k8master" ]; then
  init_kube
fi;