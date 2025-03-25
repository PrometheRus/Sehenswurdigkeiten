# Octavia (1 lb:80 -> 2 instances:8080)

_Важно:``./test_server.bin`` слушает на 8080, а не на 80м порту, как это указано по ссылке._

#### Правила доступа:
```
sg=$(openstack security group list --project demo -c ID -f value)
openstack security group rule create ${sg} --protocol icmp
openstack security group rule create ${sg} --protocol tcp --dst-port 22:22
openstack security group rule create ${sg} --protocol tcp --dst-port 80:80
openstack security group rule create ${sg} --protocol tcp --dst-port 8080:8080
```
#### Создать 2 инстанса на разных HV:
```
openstack server create --hint hypervisor_hostname=devstack-1 --image "$(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}')" --flavor 1 --nic net-id="$(openstack network list | awk '/ private / {print $2}')" instance1
openstack server create --hint hypervisor_hostname=devstack-3 --image "$(openstack image list | awk '/ cirros-.*-x86_64-.* / {print $2}')" --flavor 1 --nic net-id="$(openstack network list | awk '/ private / {print $2}')" instance2
openstack server list 
```
##### Создать ЛБ:
```
openstack loadbalancer create --wait --name lb1 --vip-subnet-id private-subnet
openstack loadbalancer listener create --wait --protocol HTTP --protocol-port 80 --name listener1 lb1
openstack loadbalancer pool create --wait --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP --name pool1
openstack loadbalancer healthmonitor create --wait --delay 5 --timeout 2 --max-retries 1 --type HTTP pool1
```
#### Добавить инстансы в группу:
```
openstack loadbalancer member create --wait --subnet-id private-subnet --address {{ REPLACE ME }} --protocol-port 8080 pool1
openstack loadbalancer member create --wait --subnet-id private-subnet --address {{ REPLACE ME }} --protocol-port 8080 pool1
```

#### Проверяем, что 2 инстанса и ЛБ с одной амфорой созданы:
```commandline
stack@devstack-2:~/devstack$ openstack loadbalancer list
+---------------------+------+---------------------+-------------+---------------------+------------------+----------+
| id                  | name | project_id          | vip_address | provisioning_status | operating_status | provider |
+---------------------+------+---------------------+-------------+---------------------+------------------+----------+
| b93a3252-d1de-4c63- | lb1  | ef517dbbcb24451e931 | 10.12.0.52  | ACTIVE              | ONLINE           | amphora  |
| 935e-5ccefa1a6505   |      | 401b712603680       |             |                     |                  |          |
+---------------------+------+---------------------+-------------+---------------------+------------------+----------+
stack@devstack-2:~/devstack$ openstack loadbalancer amphora list
+---------------------------------+----------------------------------+-----------+------------+---------------+------------+
| id                              | loadbalancer_id                  | status    | role       | lb_network_ip | ha_ip      |
+---------------------------------+----------------------------------+-----------+------------+---------------+------------+
| ebbf3141-1a35-4cc6-82fc-        | b93a3252-d1de-4c63-935e-         | ALLOCATED | STANDALONE | 192.168.0.189 | 10.12.0.52 |
| d4a102136b75                    | 5ccefa1a6505                     |           |            |               |            |
+---------------------------------+----------------------------------+-----------+------------+---------------+------------+
stack@devstack-2:~/devstack$ openstack server list
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
| ID                                   | Name      | Status | Networks                                    | Image                    | Flavor  |
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
| 614a5bc3-7a62-4595-8d20-3b00682eb0d9 | instance2 | ACTIVE | private=10.12.0.21, fd::f816:3eff:fe9b:72c5 | cirros-0.6.3-x86_64-disk | m1.tiny |
| a1d15206-1a59-4332-ac35-fe296950ebb5 | instance1 | ACTIVE | private=10.12.0.15, fd::f816:3eff:febc:92fd | cirros-0.6.3-x86_64-disk | m1.tiny |
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
```

#### Запустить демо-веб-сервер на инстансах (пароль ``gocubsgo``):
```
INST_IP={{ REPLACE ME INSTANCE1 IP }}
scp -O /opt/octavia-tempest-plugin/test_server.bin cirros@${INST_IP}:
ssh -f cirros@${INST_IP} ./test_server.bin -id ${INST_IP}

INST_IP={{ REPLACE ME INSTANCE2 IP }}
scp -O /opt/octavia-tempest-plugin/test_server.bin cirros@${INST_IP}:
ssh -f cirros@${INST_IP} ./test_server.bin -id ${INST_IP}
```

#### Курлык:
```
stack@devstack-2:~/devstack$ for val in {1..5}; do curl -w "\n" 10.12.0.52; sleep 3s; done
10.12.0.15
10.12.0.21
10.12.0.15
10.12.0.21
10.12.0.15
```

#### ssh до амфоры:
```
ssh ubuntu@192.168.0.111 -i /etc/octavia/.ssh/octavia_ssh_key
```

## Далее переходи к файлу Migrations.md