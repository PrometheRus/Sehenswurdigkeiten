# Devstack: Controller Node + 2 Compute Nodes

## Пока проблема с etcd.service, надо сделать отдельный сервис

<details>
  <summary>Подготовь файл с секретами в ./Terraform/_secerts.tf</summary>

  ```
  variable "domain" {
    default     = "{{ REPLACE ME }}"
    type        = string
    description = "The id of the user account"
    sensitive   = true
  }
  
  variable "project-id" {
    default     = "{{ REPLACE ME }}"
    type        = string
    description = "The id of the project"
  }
  
  variable "service-account-name" {
    default     = "{{ REPLACE ME }}"
    type        = string
    description = "The name of the service account"
    sensitive   = true
  }
  
  variable "service-account-password" {
    default     = "{{ REPLACE ME }}"
    type        = string
    description = "The password of the service account"
    sensitive   = true
  }
  
  variable "service-account-id" {
    default     = "{{ REPLACE ME }}"
    type        = string
    description = "The ID of the service account"
    sensitive   = true
  }
  ```
</details>

### Ожидаемый результат: 
1. ноды развернуты
   + devstack-1 (controller + octavia
   + devstack-2 (compute)
   + devstack-3 (compute)
2. все сервисы devstack@*, включая Octavia, в статусе running

### Шаги выполнения:
1. Запустить создание ВМ через terraform:
```commandline
cd TerraformCluster
terraform fmt && terraform validate
terraform plan
terraform apply
```
Отслеживать выполнение скрипта cloud-init можно через:
```commandline
ssh root@$(terraform output -raw controller) "tail -f /var/log/cloud-init-output.log"
ssh root@$(terraform output -raw cmp1) "tail -f /var/log/cloud-init-output.log"
ssh root@$(terraform output -raw cmp2) "tail -f /var/log/cloud-init-output.log"
```

```commandline
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
stack@devstack-2:~$ systemctl list-units | grep 'Devstack devstack@*'
```

# Далее переходи к файлу Octavia.md