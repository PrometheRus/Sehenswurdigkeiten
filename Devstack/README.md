# Devstack: Controller (all in one) Node + 2 Compute Nodes
1. Подготовить 3 ВМ через terraform:
```commandline
cd Terraform
terraform fmt && terraform validate
terraform plan
terraform apply
```

2. **Локально** запустить команды с предварительной заменой значений в переменных ``{{ ... }}``:
```commandline
# Assign node's IP (look at the terraform's output)
node1="{{ REPLACE ME NODE1 IP }}"
node2="{{ REPLACE ME NODE2 IP }}"
node3="{{ REPLACE ME NODE3 IP }}"

tee ~/.ssh/template_config > /dev/null <<EOF
Host *
 StrictHostKeyChecking no
 IdentityFile ~/.ssh/virt
 UserKnownHostsFile /dev/null
EOF

# Send private key to root's & stack's ssh dirs
for node in $node1 $node2 $node3; do rsync -avhpP ~/.ssh/virt root@${node}:/root/.ssh/; done
for node in $node1 $node2 $node3; do rsync -avhpP ~/.ssh/virt root@"${node}":/opt/stack/.ssh/; done

# Send ssh config to root's & stack's ssh dir
for node in $node1 $node2 $node3; do rsync -avhpP ~/.ssh/template_config root@"${node}":/root/.ssh/config; done
for node in $node1 $node2 $node3; do rsync -avhpP ~/.ssh/template_config root@"${node}":/opt/stack/.ssh/config; done

# Correct modes and owners
for node in $node1 $node2 $node3; do
  ssh root@${node} "chmod 600 /root/.ssh/config; chown -R root:root /root/.ssh/; chown -R stack:stack /opt/stack/.ssh; chmod 700 /opt/stack/.ssh; chmod 600 /opt/stack/.ssh/config";
done

# Clean up after yourself
rm -fv ~/.ssh/template_config


### Send local.conf to a VM
rsync -avhpP ./local-conf/compute_local_1.conf root@"${node1}":/opt/stack/devstack/local.conf
rsync -avhpP ./local-conf/octavia_controller.conf root@"${node2}":/opt/stack/devstack/local.conf
rsync -avhpP ./local-conf/compute_local_3.conf root@"${node3}":/opt/stack/devstack/local.conf

# Correct owners
for node in $node1 $node2 $node3; do ssh root@${node} "chown stack:stack /opt/stack/devstack/local.conf"; done
```

## On nodes:
Сначала запускаем на **Controller** ноде, затем, после окончания (~75 минут), запускаем на **Compute** нодах:
```commandline
ssh {{ CONTROLLER IP | COMPUTE1 IP | COMPUTE2 IP}}
su - stack
cd devstack
screen -S devstack
./stack.sh

# crtl+a+d
```
После выполнения скрипта будет потерян доступ до ноды по SSH через публичный адрес. Чтобы восстановить доступ, необходимо запустить команды через консоль в WUI, либо предварительно зайти по SSH с соседней ноды по серому адресу:
```commandline
sudo ip route del default via 192.168.12.1
sudo ip route add default via 192.168.11.1 dev eth0
sudo ip route add 10.12.0.0/22 via {{ external_fixed_ip }} dev br-ex     # Маршрут до наших инстансов
```

Где взять **external_fixed_ip**? В примере ниже это ``192.168.12.84``
```commandline
stack@devstack-2:~/devstack$ openstack router show router1
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                     | Value                                                                                                                                                     |
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+
| admin_state_up            | UP                                                                                                                                                        |
| availability_zone_hints   |                                                                                                                                                           |
| availability_zones        |                                                                                                                                                           |
| created_at                | 2024-12-11T10:12:04Z                                                                                                                                      |
| description               |                                                                                                                                                           |
| enable_default_route_bfd  | False                                                                                                                                                     |
| enable_default_route_ecmp | False                                                                                                                                                     |
| enable_ndp_proxy          | None                                                                                                                                                      |
| external_gateway_info     | {"network_id": "fbf5ca2c-9311-4930-a258-171d7431a127", "external_fixed_ips": [{"subnet_id": "622a0eeb-5449-4c4a-b5b4-180e7651769d", "ip_address":         |
|                           | "192.168.12.84"}, {"subnet_id": "42ca8ee2-7af2-41e5-8d7c-a57ed2d40acc", "ip_address": "2001:db8::1"}], "enable_snat": true}                               |
| external_gateways         | [{'network_id': 'fbf5ca2c-9311-4930-a258-171d7431a127', 'external_fixed_ips': [{'ip_address': '192.168.12.84', 'subnet_id':                               |
|                           | '622a0eeb-5449-4c4a-b5b4-180e7651769d'}, {'ip_address': '2001:db8::1', 'subnet_id': '42ca8ee2-7af2-41e5-8d7c-a57ed2d40acc'}]}]                            |
| flavor_id                 | None                                                                                                                                                      |
| ha                        | True                                                                                                                                                      |
| id                        | 9fd22999-0402-4b9a-8216-a62dff41e110                                                                                                                      |
| interfaces_info           | [{"port_id": "acfaa537-9790-4b4a-8150-b1e2c0980828", "ip_address": "fd::1", "subnet_id": "82cd8e5b-62e9-422a-8d20-6f3528ca83f3"}, {"port_id":             |
|                           | "b9ebd70b-0cb9-4037-aca3-df184e344ffe", "ip_address": "10.12.0.1", "subnet_id": "4b940baa-d2c7-4034-813e-ca484fa77c79"}]                                  |
| name                      | router1                                                                                                                                                   |
| project_id                | 6207553435e84030872aabf043f0d467                                                                                                                          |
| revision_number           | 4                                                                                                                                                         |
| routes                    |                                                                                                                                                           |
| status                    | ACTIVE                                                                                                                                                    |
| tags                      |                                                                                                                                                           |
| tenant_id                 | 6207553435e84030872aabf043f0d467                                                                                                                          |
| updated_at                | 2024-12-11T10:12:28Z                                                                                                                                      |
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+
```

### Обнаружить (discover) поднявшиеся compute хосты в БД Nova:
```commandline
stack@devstack-2:~$ nova-manage cell_v2 discover_hosts --verbose
stack@devstack-2:~$ openstack hypervisor list
+--------------------------------------+---------------------+-----------------+---------------+-------+
| ID                                   | Hypervisor Hostname | Hypervisor Type | Host IP       | State |
+--------------------------------------+---------------------+-----------------+---------------+-------+
| f466cc18-8e7e-48cc-a67c-835c0320b90c | devstack-2          | QEMU            | 192.168.12.20 | up    |
| 573e906a-544e-4c82-acec-c443dbd72a8b | devstack-1          | QEMU            | 192.168.12.10 | up    |
| 00a23759-1e33-4eb4-bb61-d51f2e46e161 | devstack-3          | QEMU            | 192.168.12.30 | up    |
+--------------------------------------+---------------------+-----------------+---------------+-------+
```

### Ожидаемый результат: ноды развернуты, все юниты devstack@*, включая Octavia, в статусе running

```commandline
stack@devstack-2:~$ systemctl list-units | grep 'Devstack devstack@*'
  devstack@c-api.service                                                                       loaded active running   Devstack devstack@c-api.service
  devstack@c-sch.service                                                                       loaded active running   Devstack devstack@c-sch.service
  devstack@c-vol.service                                                                       loaded active running   Devstack devstack@c-vol.service
  devstack@dstat.service                                                                       loaded active running   Devstack devstack@dstat.service
  devstack@etcd.service                                                                        loaded active running   Devstack devstack@etcd.service
  devstack@g-api.service                                                                       loaded active running   Devstack devstack@g-api.service
  devstack@keystone.service                                                                    loaded active running   Devstack devstack@keystone.service
  devstack@n-api-meta.service                                                                  loaded active running   Devstack devstack@n-api-meta.service
  devstack@n-api.service                                                                       loaded active running   Devstack devstack@n-api.service
  devstack@n-cond-cell1.service                                                                loaded active running   Devstack devstack@n-cond-cell1.service
  devstack@n-cpu.service                                                                       loaded active running   Devstack devstack@n-cpu.service
  devstack@n-novnc-cell1.service                                                               loaded active running   Devstack devstack@n-novnc-cell1.service
  devstack@n-sch.service                                                                       loaded active running   Devstack devstack@n-sch.service
  devstack@n-super-cond.service                                                                loaded active running   Devstack devstack@n-super-cond.service
  devstack@o-api.service                                                                       loaded active running   Devstack devstack@o-api.service
  devstack@o-cw.service                                                                        loaded active running   Devstack devstack@o-cw.service
  devstack@o-da.service                                                                        loaded active running   Devstack devstack@o-da.service
  devstack@o-hk.service                                                                        loaded active running   Devstack devstack@o-hk.service
  devstack@o-hm.service                                                                        loaded active running   Devstack devstack@o-hm.service
  devstack@placement-api.service                                                               loaded active running   Devstack devstack@placement-api.service
  devstack@q-ovn-metadata-agent.service                                                        loaded active running   Devstack devstack@q-ovn-metadata-agent.service
  devstack@q-svc.service                                                                       loaded active running   Devstack devstack@q-svc.service
```

#### Если сделали ребут и нужно поднять линки:
```commandline
### Выполнять после ребута
ip a add 192.168.12.10/25 dev br-ex; ip l set up br-ex; ip l set up br-int  # Node1
ip a add 192.168.12.20/25 dev br-ex; ip l set up br-ex; ip l set up br-int  # Node2
ip a add 192.168.12.30/25 dev br-ex; ip l set up br-ex; ip l set up br-int  # Node3
```