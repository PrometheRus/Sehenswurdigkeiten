```
This is your host IP address: 192.168.100.135
This is your host IPv6 address: ::1
Horizon is now available at http://192.168.100.135/dashboard
Keystone is serving at http://192.168.100.135/identity/
The default users are: admin and demo
The password: uWZ0Qjyi792s9PW

WARNING: 
Configuring uWSGI with a WSGI file is deprecated, use module paths instead
Configuring uWSGI with a WSGI file is deprecated, use module paths instead
Configuring uWSGI with a WSGI file is deprecated, use module paths instead


Services are running under systemd unit files.
For more information see: 
https://docs.openstack.org/devstack/latest/systemd.html

DevStack Version: 2025.1
Change: 9486709dc5e6f156dc5beb051f1861ea362ae10c Revert "Install simplejson in devstack venv" 2024-12-03 17:15:40 +0000
OS Version: Ubuntu 24.04 noble

2024-12-05 13:03:49.737 | stack.sh completed in 2581 seconds.
```
### Сделал ребут - все поднялось


```
# create nova instances on private network
openstack server create --image $(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}') --flavor 1 --nic net-id=$(openstack network list | awk '/ private / {print $2}') node1
openstack server create --image $(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}') --flavor 1 --nic net-id=$(openstack network list | awk '/ private / {print $2}') node2
openstack server list # should show the nova instances just created

# add secgroup rules to allow ssh etc..
openstack security group rule create default --protocol icmp
openstack security group rule create default --protocol tcp --dst-port 22:22
openstack security group rule create default --protocol tcp --dst-port 80:80
```

## Octavia
```
apt update && apt install -y git
useradd -s /bin/bash -d /opt/stack -m stack
chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/stack
sudo -u stack -i;
git clone https://opendev.org/openstack/devstack; cd devstack;

tee /opt/stack/devstack/local.conf > /dev/null <<EOF
[[local|localrc]]
# ===== BEGIN localrc =====
ADMIN_PASSWORD=uWZ0Qjyi792s9PW
DATABASE_PASSWORD=uWZ0Qjyi792s9PW
SERVICE_PASSWORD=uWZ0Qjyi792s9PW
SERVICE_TOKEN=uWZ0Qjyi792s9PW
RABBIT_PASSWORD=uWZ0Qjyi792s9PW
# GIT_BASE=https://opendev.org
# Optional settings:
# OCTAVIA_AMP_BASE_OS=centos
# OCTAVIA_AMP_DISTRIBUTION_RELEASE_ID=9-stream
# OCTAVIA_AMP_IMAGE_SIZE=3
# OCTAVIA_LB_TOPOLOGY=ACTIVE_STANDBY
# OCTAVIA_ENABLE_AMPHORAV2_JOBBOARD=True
# LIBS_FROM_GIT+=octavia-lib,
# Enable Logging
LOGFILE=$DEST/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=True
enable_service rabbit
enable_plugin neutron $GIT_BASE/openstack/neutron
# Octavia supports using QoS policies on the VIP port:
enable_service q-qos
enable_service placement-api placement-client
# Octavia services
enable_plugin octavia $GIT_BASE/openstack/octavia master
enable_plugin octavia-dashboard $GIT_BASE/openstack/octavia-dashboard
enable_plugin ovn-octavia-provider $GIT_BASE/openstack/ovn-octavia-provider
enable_plugin octavia-tempest-plugin $GIT_BASE/openstack/octavia-tempest-plugin
enable_service octavia o-api o-cw o-hm o-hk o-da
# If you are enabling barbican for TLS offload in Octavia, include it here.
# enable_plugin barbican $GIT_BASE/openstack/barbican
# enable_service barbican
# Cinder (optional)
disable_service c-api c-vol c-sch
# Tempest
enable_service tempest
# ===== END localrc =====
EOF

./stack.sh
. ./openrc

openstack network list

# create nova instances on private network
openstack server create --image $(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}') --flavor 1 --nic net-id=$(openstack network list | awk '/ private / {print $2}') node1
openstack server create --image $(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}') --flavor 1 --nic net-id=$(openstack network list | awk '/ private / {print $2}') node2
openstack server list # should show the nova instances just created

# add secgroup rules to allow ssh etc..
openstack security group rule create default --protocol icmp
openstack security group rule create default --protocol tcp --dst-port 22:22
openstack security group rule create default --protocol tcp --dst-port 80:80
```