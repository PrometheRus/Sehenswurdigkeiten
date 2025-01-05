#!/bin/bash

# https://docs.openstack.org/octavia/latest/install/install-ubuntu.html

MYSQL_PASS="LnCK43Fxg8#"
# Mysql Octavia
mysql -e "CREATE DATABASE octavia;"
mysql -e "CREATE USER 'octavia'@'%' IDENTIFIED BY '${MYSQL_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON octavia.* TO 'octavia'@'%';"

### Set up Octavia
ADMIN_PASS="26qe1IG6JrT7"
openstack user create --domain default --password-prompt octavia
openstack role add --project service --user octavia admin
openstack service create --name octavia --description "OpenStack Octavia" load-balancer
openstack endpoint create --region RegionOne load-balancer public http://controller:9876
openstack endpoint create --region RegionOne load-balancer internal http://controller:9876
openstack endpoint create --region RegionOne load-balancer admin http://controller:9876
tee $HOME/octavia-openrc > /dev/null <<EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=service
export OS_USERNAME=octavia
export OS_PASSWORD="${ADMIN_PASS}"
export OS_AUTH_URL=http://controller:5000
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=3
EOF
# Here I need to build an image (https://docs.openstack.org/octavia/latest/admin/amphora-image-build.html)
openstack image create --disk-format qcow2 --container-format bare --private --tag amphora --file <path to the amphora image> amphora-x64-haproxy
openstack flavor create --id 200 --vcpus 1 --ram 1024 --disk 2 "amphora" --private
apt install octavia-api octavia-health-manager octavia-housekeeping octavia-worker python3-octavia python3-octaviaclient

# Create certificates
git clone https://opendev.org/openstack/octavia.git
cd octavia/bin/
source create_dual_intermediate_CA.sh
sudo mkdir -p /etc/octavia/certs/private
sudo chmod 755 /etc/octavia -R
sudo cp -p etc/octavia/certs/server_ca.cert.pem /etc/octavia/certs
sudo cp -p etc/octavia/certs/server_ca-chain.cert.pem /etc/octavia/certs
sudo cp -p etc/octavia/certs/server_ca.key.pem /etc/octavia/certs/private
sudo cp -p etc/octavia/certs/client_ca.cert.pem /etc/octavia/certs
sudo cp -p etc/octavia/certs/client.cert-and-key.pem /etc/octavia/certs/private

source $HOME/octavia-openrc
openstack security group create lb-mgmt-sec-grp
openstack security group rule create --protocol icmp lb-mgmt-sec-grp
openstack security group rule create --protocol tcp --dst-port 22 lb-mgmt-sec-grp
openstack security group rule create --protocol tcp --dst-port 9443 lb-mgmt-sec-grp
openstack security group create lb-health-mgr-sec-grp
openstack security group rule create --protocol udp --dst-port 5555 lb-health-mgr-sec-grp

openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey

cd $HOME
sudo mkdir -m755 -p /etc/dhcp/octavia
sudo cp octavia/etc/dhcp/dhclient.conf /etc/dhcp/octavia

OCTAVIA_MGMT_SUBNET=172.16.0.0/12
OCTAVIA_MGMT_SUBNET_START=172.16.0.100
OCTAVIA_MGMT_SUBNET_END=172.16.31.254
OCTAVIA_MGMT_PORT_IP=172.16.0.2

openstack network create lb-mgmt-net
openstack subnet create --subnet-range $OCTAVIA_MGMT_SUBNET --allocation-pool \
  start=$OCTAVIA_MGMT_SUBNET_START,end=$OCTAVIA_MGMT_SUBNET_END \
  --network lb-mgmt-net lb-mgmt-subnet

SUBNET_ID=$(openstack subnet show lb-mgmt-subnet -f value -c id)
PORT_FIXED_IP="--fixed-ip subnet=$SUBNET_ID,ip-address=$OCTAVIA_MGMT_PORT_IP"

MGMT_PORT_ID=$(openstack port create --security-group \
  lb-health-mgr-sec-grp --device-owner Octavia:health-mgr \
  --host=$(hostname) -c id -f value --network lb-mgmt-net \
PORT_FIXED_IP octavia-health-manager-listen-port)

MGMT_PORT_MAC=$(openstack port show -c mac_address -f value \
MGMT_PORT_ID)

sudo ip link add o-hm0 type veth peer name o-bhm0
NETID=$(openstack network show lb-mgmt-net -c id -f value)
BRNAME=brq$(echo $NETID|cut -c 1-11)
sudo brctl addif $BRNAME o-bhm0
sudo ip link set o-bhm0 up

sudo ip link set dev o-hm0 address $MGMT_PORT_MAC
sudo iptables -I INPUT -i o-hm0 -p udp --dport 5555 -j ACCEPT
sudo dhclient -v o-hm0 -cf /etc/dhcp/octavia