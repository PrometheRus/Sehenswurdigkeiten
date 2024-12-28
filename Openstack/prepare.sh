#!/bin/bash

tee -a /etc/hosts > /dev/null <<EOF

192.168.11.10 controller
192.168.11.20 cmp1
192.168.11.30 cmp2
EOF

### Действия выполняются руками, так как неудобно через IaC
# ROOT_PASS="DemoPassword134!"
mysql_config_editor -v set --user root --password


MYSQL_PASS="LnCK43Fxg8#"
# Keystone
mysql -e "CREATE DATABASE keystone; "
mysql -e "CREATE USER 'keystone'@'%' IDENTIFIED BY '${MYSQL_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%';"

# Neutron
mysql -e "CREATE DATABASE neutron;"
mysql -e "CREATE USER 'neutron'@'%' IDENTIFIED BY '${MYSQL_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%';"


# Init Keystone
grep -ni '#connection = <None>/' /etc/keystone/keystone.conf
sed -i "s/#connection = <None>/connection = mysql+pymysql:\/\/keystone:${MYSQL_PASS}@controller\/keystone/"
grep -ni 'connection = mysql' /etc/keystone/keystone.conf

vi /etc/keystone/keystone.conf +2602
# provider = fernet

su -s /bin/sh -c "keystone-manage db_sync" keystone

ADMIN_PASS="26qe1IG6JrT7"
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password "${ADMIN_PASS}" \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne


# Apache
grep -ni "#ServerName www.example.com:80" /etc/httpd/conf/httpd.conf
sed -i 's/#ServerName www.example.com:80/ServerName controller/' /etc/httpd/conf/httpd.conf
grep -ni "ServerName" /etc/httpd/conf/httpd.conf
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
systemctl enable httpd.service
systemctl start httpd.service

tee > admin-openrc /dev/null <<EOF
export OS_USERNAME=admin
export OS_PASSWORD="{{ADMIN_PASS}}"
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
ADMIN_PASS="26qe1IG6JrT7"
sed -i "s/{{ADMIN_PASS}}/${ADMIN_PASS}/" admin-openrc
source admin-openrc


# Проверка

# [root@keystone ~]# openstack user list
# +----------------------------------+-------+
# | ID                               | Name  |
# +----------------------------------+-------+
# | 385939446fa64b30a331d60bbc25317e | admin |
# +----------------------------------+-------+
# [root@keystone ~]# openstack network list
# public endpoint for compute service not found
# [root@keystone ~]# openstack service list
# +----------------------------------+----------+----------+
# | ID                               | Name     | Type     |
# +----------------------------------+----------+----------+
# | e90e16507c874ad0b743505583d607c0 | keystone | identity |
# +----------------------------------+----------+----------+



# Init NEUTRON
ADMIN_PASS="26qe1IG6JrT7"

tee > admin-openrc /dev/null <<EOF
export OS_USERNAME=admin
export OS_PASSWORD="{{ADMIN_PASS}}"
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
ADMIN_PASS="26qe1IG6JrT7"
sed -i "s/{{ADMIN_PASS}}/${ADMIN_PASS}/" admin-openrc
source admin-openrc

openstack user create --domain default --password-prompt neutron
openstack project create service
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696