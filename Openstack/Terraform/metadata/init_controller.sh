#!/bin/bash

timedatectl set-timezone Europe/Moscow
dnf install -y golang-github-prometheus-node-exporter
systemctl start prometheus-node-exporter.service

tee -a /etc/hosts > /dev/null <<EOF

192.168.11.10 controller
192.168.11.20 cmp1
192.168.11.30 cmp2
192.168.11.40 grafana
EOF

# Install Percona
ROOT_PASS="DemoPassword134\!"
sudo yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo percona-release setup ps-80
sudo yum -y install percona-server-server

systemctl stop mysqld; systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"; systemctl start mysqld
mysql -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';"
systemctl stop mysqld; systemctl unset-environment MYSQLD_OPTS; systemctl start mysqld


# Install Openstack
dnf install -y dnf-plugins-core
dnf config-manager --set-enabled crb
dnf install -y centos-release-openstack-zed
dnf upgrade -y
dnf install -y python3-openstackclient openstack-selinux

# Install Keystone
dnf install -y openstack-keystone httpd python3-mod_wsgi

# Install RabbitMQ
dnf install -y erlang logrotate rabbitmq-server
systemctl start rabbitmq-server
transport_url="transport_url = rabbit://username:password@kafkahostname:9092"