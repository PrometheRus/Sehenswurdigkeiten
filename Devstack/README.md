# Devstack: Controller Node + 2 Compute Nodes

## 0. Prerequisites:
#### Ваши секреты сервисного аккаунта и прочая добавить в директорию Terraform:
```commandline
tee ./secret.tfvars > /dev/null << EOF
domain                   = "<domain>"
project-id               = "<project-id>"
service-account-name     = "<project-admin-service-account-name>"
service-account-password = "<pass>"
service-account-id       = "<id>"
service-ssh-key-name     = "<name>"
EOF
```
#### Ваши секреты объектного хранилища для сохранения ```terraform.state``` удаленно (либо удалите полностью блок ```backend``` из ```main.tf```):
```commandline
tee ./secret.backend.tfvars > /dev/null << EOF
bucket     = "<bucket>"
access_key = "<key>"
secret_key = "<key>"
EOF
```

## 1. Deployment

```commandline
cd Sehenswurdigkeiten/Grafana/Terraform/
terraform init -backend-config=secret.backend.tfvars
terraform apply -var-file=secret.tfvars -auto-approve
```

Ждем выполнения:
```commandline
ssh root@$(terraform output -raw controller) tail -f /var/log/cloud-init-output.log
ssh root@$(terraform output -raw cmp1) tail -f /var/log/cloud-init-output.log
ssh root@$(terraform output -raw cmp2) tail -f /var/log/cloud-init-output.log
```
После выполнения запустить команду на controller (TO UPDATE):
```commandline
nova-manage cell_v2 discover_hosts
```

### Ожидаемый результат: 
ноды развернуты:
  + devstack-1 (controller + octavia)
  + devstack-2 (compute)
  + devstack-3 (compute)
```
stack@devstack-2:~$ openstack hypervisor list
+--------------------------------------+---------------------+-----------------+---------------+-------+
| ID                                   | Hypervisor Hostname | Hypervisor Type | Host IP       | State |
+--------------------------------------+---------------------+-----------------+---------------+-------+
| f466cc18-8e7e-48cc-a67c-835c0320b90c | devstack-2          | QEMU            | 192.168.12.20 | up    |
| 573e906a-544e-4c82-acec-c443dbd72a8b | devstack-1          | QEMU            | 192.168.12.10 | up    |
| 00a23759-1e33-4eb4-bb61-d51f2e46e161 | devstack-3          | QEMU            | 192.168.12.30 | up    |
+--------------------------------------+---------------------+-----------------+---------------+-------+
```
#### Маршрут от controller до наших инстансов
```commandline
sudo ip route add 10.12.0.0/22 via {{ external_fixed_ip }} dev br-ex     # 

# Где взять external_fixed_ip?
openstack router show router1 -f json | jq '.external_gateway_info.external_fixed_ips[0].ip_address'
```
## Далее переходи к файлу Octavia.md