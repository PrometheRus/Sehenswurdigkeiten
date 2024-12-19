# Devstack: Controller Node + 2 Compute Nodes

### Ожидаемый результат: 
1. ноды развернуты
   + devstack-1 (compute)
   + devstack-2 (controller + octavia)
   + devstack-3 (compute)
2. все сервисы devstack@*, включая Octavia, в статусе running

## Шаги выполнения:
1. Подготовить 3 ВМ через terraform:
```commandline
cd TerraformCluster
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

cd ..
tee ~/.ssh/template_config > /dev/null <<EOF
Host *
 StrictHostKeyChecking no
 IdentityFile ~/.ssh/virt
 UserKnownHostsFile /dev/null
EOF

tee ~/.ssh/template_auth > /dev/null <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Qs3Wltt98Hx2A+dXIPFZEAgJ38afG9BOnxeeR41Bk For using VMs
EOF

for node in $node1 $node2 $node3; do ssh root@${node} "mkdir --mode 700 /opt/stack/.ssh; chown stack:stack /opt/stack/.ssh/"; done

# Send private key to root's & stack's ssh dirs
for node in $node1 $node2 $node3; do rsync -ahpP ~/.ssh/virt root@${node}:/root/.ssh/; done
for node in $node1 $node2 $node3; do rsync -ahpP ~/.ssh/virt root@${node}:/opt/stack/.ssh/; done

# Send ssh config to root's & stack's ssh dir
for node in $node1 $node2 $node3; do rsync -ahpP ~/.ssh/template_config root@"${node}":/root/.ssh/config; done
for node in $node1 $node2 $node3; do rsync -ahpP ~/.ssh/template_config root@"${node}":/opt/stack/.ssh/config; done
for node in $node1 $node2 $node3; do rsync -ahpP ~/.ssh/template_auth root@"${node}":/opt/stack/.ssh/authorized_keys; done

# Correct modes and owners
for node in $node1 $node2 $node3; do
  ssh root@${node} "chmod 600 /root/.ssh/config; chown -R root:root /root/.ssh/; chown -R stack:stack /opt/stack/.ssh; chmod 700 /opt/stack/.ssh; chmod 600 /opt/stack/.ssh/config /opt/stack/.ssh/authorized_keys";
done

# Clean up after yourself
rm -fv ~/.ssh/template_config ~/.ssh/template_auth


### Send local.conf to a VM
rsync -ahpP ./local-conf/compute_local_1.conf root@"${node1}":/opt/stack/devstack/local.conf
rsync -ahpP ./local-conf/octavia_controller.conf root@"${node2}":/opt/stack/devstack/local.conf
rsync -ahpP ./local-conf/compute_local_3.conf root@"${node3}":/opt/stack/devstack/local.conf

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