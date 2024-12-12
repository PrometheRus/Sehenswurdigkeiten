# Octavia (1 lb:80 -> 2 instances:8080)

### Выполнял по [инструкции](https://docs.openstack.org/devstack/latest/guides/devstack-with-octavia.html) 
_Важно:``./test_server.bin`` слушает на 8080, а не на 80м порту, как это указано по ссылке._

#### Правила доступа:
```
openstack security group rule create default --protocol icmp
openstack security group rule create default --protocol tcp --dst-port 22:22
openstack security group rule create default --protocol tcp --dst-port 80:80
openstack security group rule create default --protocol tcp --dst-port 8080:8080
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

#### Проверяем, что ЛБ с одной амфорой создан:
```commandline
stack@devstack-2:~$ openstack loadbalancer list
+--------------------------------------+------+----------------------------------+-------------+---------------------+------------------+----------+
| id                                   | name | project_id                       | vip_address | provisioning_status | operating_status | provider |
+--------------------------------------+------+----------------------------------+-------------+---------------------+------------------+----------+
| 46eac739-0c2c-47c6-b94b-1d4b8ba1ba8e | lb1  | d9b06f241423426f95341acffe50ad5f | 10.12.0.30  | ACTIVE              | ONLINE           | amphora  |
+--------------------------------------+------+----------------------------------+-------------+---------------------+------------------+----------+
stack@devstack-2:~$ openstack server list
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
| ID                                   | Name      | Status | Networks                                    | Image                    | Flavor  |
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
| 4d6df57d-4c7a-4481-89a8-541b1f17a528 | instance2 | ACTIVE | private=10.12.0.40, fd::f816:3eff:fe3f:91ce | cirros-0.6.3-x86_64-disk | m1.tiny |
| 961f13d2-cb26-47cb-a760-c68f2b8aabea | instance1 | ACTIVE | private=10.12.0.33, fd::f816:3eff:fe26:d3ee | cirros-0.6.3-x86_64-disk | m1.tiny |
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

### Курлык:
```
stack@devstack-2:~$ openstack loadbalancer list 
+--------------------------------------+------+----------------------------------+-------------+---------------------+------------------+----------+
| id                                   | name | project_id                       | vip_address | provisioning_status | operating_status | provider |
+--------------------------------------+------+----------------------------------+-------------+---------------------+------------------+----------+
| 46eac739-0c2c-47c6-b94b-1d4b8ba1ba8e | lb1  | d9b06f241423426f95341acffe50ad5f | 10.12.0.30  | ACTIVE              | ONLINE           | amphora  |
+--------------------------------------+------+----------------------------------+-------------+---------------------+------------------+----------+
stack@devstack-2:~$ for val in {1..5}; do curl -i 10.12.0.30; sleep 3s; done

HTTP/1.1 200 OK
set-cookie: JSESSIONID=10.12.0.40
date: Thu, 12 Dec 2024 11:05:10 GMT
content-length: 10
content-type: text/plain; charset=utf-8
10.12.0.40

HTTP/1.1 200 OK
set-cookie: JSESSIONID=10.12.0.33
date: Thu, 12 Dec 2024 11:05:14 GMT
content-length: 10
content-type: text/plain; charset=utf-8
10.12.0.33

HTTP/1.1 200 OK
set-cookie: JSESSIONID=10.12.0.40
date: Thu, 12 Dec 2024 11:05:16 GMT
content-length: 10
content-type: text/plain; charset=utf-8
10.12.0.40

HTTP/1.1 200 OK
set-cookie: JSESSIONID=10.12.0.33
date: Thu, 12 Dec 2024 11:05:20 GMT
content-length: 10
content-type: text/plain; charset=utf-8
10.12.0.33

HTTP/1.1 200 OK
set-cookie: JSESSIONID=10.12.0.40
date: Thu, 12 Dec 2024 11:05:22 GMT
content-length: 10
content-type: text/plain; charset=utf-8
10.12.0.40
```

### Задание: _"Предоставлен вывод конфига haproxy из амфоры"_:
```
stack@devstack-2:~$ ssh ubuntu@192.168.0.111 -i /etc/octavia/.ssh/octavia_ssh_key

ubuntu@amphora-6e1b4bb6-6ad8-4fec-b81f-cb7b07a8539a:~$ cat /etc/haproxy/haproxy.cfg 
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http
```