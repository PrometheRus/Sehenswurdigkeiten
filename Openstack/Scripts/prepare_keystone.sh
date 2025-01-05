#!/bin/bash

# Set up Keystone
MYSQL_PASS="LnCK43Fxg8#"
grep -ni '#connection = <None>' /etc/keystone/keystone.conf
sed -i "s/#connection = <None>/connection = mysql+pymysql:\/\/keystone:${MYSQL_PASS}@controller\/keystone/" /etc/keystone/keystone.conf
grep -ni 'connection = mysql' /etc/keystone/keystone.conf

# provider = fernet
sed -i '262i provider = fernet' /etc/keystone/keystone.conf
grep -ni 'provider = fernet' /etc/keystone/keystone.conf

#
sed -i "s/#transport_url = rabbit:\/\//transport_url = rabbit:\/\/guest:guest@localhost:5672/" /etc/keystone/keystone.conf
grep -ni '#transport_url = ' /etc/keystone/keystone.conf


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
export OS_PASSWORD="${ADMIN_PASS}"
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
source admin-openrc

# Проверка
openstack user list