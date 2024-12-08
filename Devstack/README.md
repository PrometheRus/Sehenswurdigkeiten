# Octavia
### По [инструкции](https://docs.openstack.org/devstack/latest/guides/devstack-with-octavia.html) 
1. ``./test_server.bin`` слушает на 8080, а не на 80м порту
2. Не забыть скорректировать правила security group

```
# create nova instances on private network
openstack server create --image $(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}') --flavor 1 --nic net-id=$(openstack network list | awk '/ private / {print $2}') node1
openstack server create --image $(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}') --flavor 1 --nic net-id=$(openstack network list | awk '/ private / {print $2}') node2
openstack server list # should show the nova instances just created

INST_IP=<REPLACE ME>
scp -O /opt/octavia-tempest-plugin/test_server.bin cirros@${INST_IP}:
ssh -f cirros@${INST_IP} ./test_server.bin -id ${INST_IP}

INST_IP=<REPLACE ME>
scp -O /opt/octavia-tempest-plugin/test_server.bin cirros@${INST_IP}:
ssh -f cirros@${INST_IP} ./test_server.bin -id ${INST_IP}

openstack loadbalancer member create --wait --subnet-id private-subnet --address 10.0.0.20 --protocol-port 8080 pool1
openstack loadbalancer member create --wait --subnet-id private-subnet --address 10.0.0.26 --protocol-port 8080 pool1
openstack security group rule create default --protocol icmp
openstack security group rule create default --protocol tcp --dst-port 22:22
openstack security group rule create default --protocol udp --dst-port 80:80
openstack security group rule create default --protocol udp --dst-port 8080:8080
```