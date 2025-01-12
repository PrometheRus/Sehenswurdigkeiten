#!/bin/bash

prepare_basic() {
  timedatectl set-timezone Europe/Moscow
  apt-get install -qy git nmap telnet openssl jq
}

prepare_devstack() {
  git clone https://opendev.org/openstack/devstac
  ./devstack/tools/create-stack-user.sh
  mv devstack /opt/stack
  chown -R stack:stack /opt/stack/devstack
}

prepare_conf() {
  echo "TODO()"
}

prepare_basic
prepare_devstack