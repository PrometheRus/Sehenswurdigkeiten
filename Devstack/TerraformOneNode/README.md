# Devstack: Controller Node + 2 Compute Nodes

### Ожидаемый результат: 
1. ноды развернуты
   + devstack-1 (All in one)
2. все сервисы devstack@*, ~~включая Octavia~~, в статусе running

## Шаги выполнения:
1. Подготовить 1 ВМ через terraform:
```commandline
cd TerraformOneONde
terraform fmt && terraform validate
terraform plan
terraform apply
```

2. **Локально** запустить с предварительной заменой значений в переменных ``{{ ... }}``:
```commandline
# Assign node's IP (look at the terraform's output)
node="{{ REPLACE ME NODE1 IP }}"

### Send local.conf to a VM
rsync -ahpP ./metadata/local.conf root@${node}:/opt/stack/devstack/local.conf

# Correct owners
ssh root@${node} "chown stack:stack /opt/stack/devstack/local.conf"
```

## On nodes:
```commandline
ssh ${node}
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

Где взять **external_fixed_ip**?
```commandline
openstack router show router1 -f json | jq '.external_gateway_info.external_fixed_ips[0].ip_address'
```

### Обнаружить (discover) поднявшиеся compute хосты в БД Nova:
```commandline
stack@devstack-2:~$ nova-manage cell_v2 discover_hosts
```

### Фактический результат: ноды развернуты, все сервисы devstack@*, включая Octavia, в статусе running
```commandline
stack@devstack-2:~$ openstack hypervisor list
+--------------------------------------+---------------------+-----------------+---------------+-------+
| ID                                   | Hypervisor Hostname | Hypervisor Type | Host IP       | State |
+--------------------------------------+---------------------+-----------------+---------------+-------+
| f466cc18-8e7e-48cc-a67c-835c0320b90c | devstack-2          | QEMU            | 192.168.12.20 | up    |
| 573e906a-544e-4c82-acec-c443dbd72a8b | devstack-1          | QEMU            | 192.168.12.10 | up    |
| 00a23759-1e33-4eb4-bb61-d51f2e46e161 | devstack-3          | QEMU            | 192.168.12.30 | up    |
+--------------------------------------+---------------------+-----------------+---------------+-------+
```

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

# Далее переходи к файлу Octavia.md