#!/bin/bash

source keystone-openrc

etcdctl get GLANCE_PASS --print-value-only
openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

# Creds
tee > glance-openrc /dev/null <<EOF
export OS_USERNAME=glance
export OS_PASSWORD="$(etcdctl get GLANCE_PASS --print-value-only)"
export OS_PROJECT_NAME=service
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
source glance-openrc

### Не смог это пройти, так как:
# You are not authorized to perform the requested action: identity:create_registered_limits. (HTTP 403) (Request-ID: req-43db3c32-d64a-4ad8-9266-6f26421663a2)
# Optional
#openstack registered limit create --service glance --default-limit 1000 --region RegionOne image_size_total
#openstack registered limit create --service glance --default-limit 1000 --region RegionOne image_stage_total
#openstack registered limit create --service glance --default-limit 100 --region RegionOne image_count_total
#openstack registered limit create --service glance --default-limit 100 --region RegionOne image_count_uploading

dnf install -qy openstack-glance

tee /etc/glance/glance-api.conf > /dev/null <<EOF
[DEFAULT]
transport_url = rabbit://guest:guest@localhost:5672/
use_journal = true
enabled_backends=fs:file
# use_keystone_limits = True    # Надо решить с лемитами выше

[glance_store]
default_backend = fs

[fs]
filesystem_store_datadir = /var/lib/glance/images/

[database]
connection = mysql+pymysql://glance:$(etcdctl get MYSQL_PASS --print-value-only)@controller/glance

[keystone_authtoken]
www_authenticate_uri  = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = $(etcdctl get GLANCE_PASS --print-value-only)

[paste_deploy]
flavor = keystone

[oslo_limit]
auth_url = http://controller:5000
auth_type = password
user_domain_id = default
username = glance
system_scope = all
password = $(etcdctl get GLANCE_PASS --print-value-only)
endpoint_id = $(openstack endpoint list --service glance --region RegionOne --interface public -f value -c ID)
region_name = RegionOne

EOF
openstack role add --user glance --user-domain Default --system all reader

su -s /bin/sh -c "glance-manage db_sync" glance
systemctl enable openstack-glance-api.service
systemctl start openstack-glance-api.service

wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
glance image-create --name "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility=public