#!/bin/bash

### Set up NEUTRON
NEUTRON_PASS="26qe1IG6JrT7"

tee > admin-openrc /dev/null <<EOF
export OS_USERNAME=admin
export OS_PASSWORD="${NEUTRON_PASS}"
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
source admin-openrc

openstack user create --domain default --password-prompt neutron
openstack project create service
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696

# Проверка
openstack service list

dnf -y install openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch ebtables

MYSQL_PASS="LnCK43Fxg8#"
RABBIT_LOGIN="guest"
RABBIT_PASS="guest"
sed -i "s/{{ MYSQL_PASS }} /${MYSQL_PASS}/; s/{{ RABBIT_LOGIN }}/${RABBIT_LOGIN}/; s/{{ RABBIT_PASS }}/${RABBIT_PASS}/" /etc/neutron/neutron.conf
sed -i "s/{{ NEUTRON_PASS }} /${NEUTRON_PASS}/; s/{{ NOVA_PASS }} /${NOVA_PASS}/" /etc/neutron/neutron.conf
