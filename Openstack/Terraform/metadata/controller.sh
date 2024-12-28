#!/bin/bash

timedatectl set-timezone Europe/Moscow

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