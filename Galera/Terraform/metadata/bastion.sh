#!/bin/bash

timedatectl set-timezone Europe/Moscow
yum -y update

tee ./.ssh/config > /dev/null <<EOF
Host *
  IdentityFile ~/.ssh/virt
  StrictHostKeyChecking no
EOF

chmod 600 ./.ssh/config;