# Кластер Galera с MySQL на **Ubuntu 24.04 LTS**

### Предварительные условия:
1. Подготовить локально openstack cli (по [инструкции](https://docs.selectel.ru/en/cloud/servers/tools/openstack/))
2. Создать сервисный аккаунт (по инструкции) с ролями:
   1. ``Администратор <project-name>``
   2. ``Администратор пользователей``
3. Подготовить локально Terraform (по [инструкции](https://docs.selectel.ru/terraform/quickstart/))
4. Заполнить переменные Terraform **своими** значениями в файле `./1.Terraform/_vars.tf`
   + selectel-domain
   + selectel-project-id
   + service-account-name
   + service-account-password
   + service-account-id
5. Сгенерировать ssh-ключ, который будет использоваться для доступа к виртуальным машинам:
   ```
   ssh-keyen -t ed25519 -f ~/.ssh/virt
   ```
6. Установить anisble-core

## 1.1. Manual deployment (openstack cli)
### Шаги выполнения

<details>
  <summary>Шаги выполнения</summary>

  ```
  #!/bin/bash

  Create net + subnet + router + ports
  openstack network create network_1
  openstack subnet create subnet_1 --network network_1 --subnet-range 192.168.199.0/24
  openstack router create router_1
  openstack router set router_1 --external-gateway external-network
  openstack router add subnet router_1 subnet_1
  for val in {1..4}; do openstack port create -q --network network_1 --fixed-ip subnet=subnet_1,ip-address=192.168.199.4${val} port${val}; done
  openstack floating ip create -q external-network --port port4
    
  # Create volumes
  image="b671a80e-9bf0-4861-9833-bd711bd8a02f" # Ubuntu 24.04
  for val in {1..4}; do openstack volume create -q --image ${image} --size 10 --type basic.ru-9a --availability-zone ru-9a boot-volume-${val}; done
  
  # Create VMs
  ssh-keygen -t ed25519 -f "$HOME/.ssh/virt" -q -N ""
  openstack keypair create --public-key "$HOME/.ssh/virt" keypair_1
  
  flavor='1012'
  for val in {1..4}; do
   openstack server create server_"${val}" \
   --flavor ${flavor} \
   --volume boot-volume-"${val}" \
   --port port"${val}" \
   --key-name keypair_1 \
   --availability-zone ru-9a;
  done
    
  # Create a loadbalancer
  openstack loadbalancer create --name lb_1 --vip-address 192.168.199.45 --vip-port-id port5 --flavor AMPH1.SNGL.2-1024
  sleep 120s;
  openstack loadbalancer listener create --name listener_1 --protocol TCP --protocol-port 3306 lb_1
  sleep 10;
  openstack loadbalancer pool create --name pool_1 --lb-algorithm ROUND_ROBIN --listener listener_1 --protocol TCP
  sleep 10;
  for val in {1..3}; do openstack loadbalancer member create --subnet-id subnet_1 --address 192.168.199.4${val} --protocol-port 3306 pool_1; sleep 10s; done
  openstack floating ip create external-network --port "$(openstack port list -f value | grep 192.168.199.45 | cut -f 1 -d ' ')"
  openstack loadbalancer healthmonitor create --delay 5 --max-retries 4 --timeout 10 --type TCP pool_1

  ```
</details>

## 1.2 Automatic deployment (Terraform):

```
git clone git@github.com:PrometheRus/Sehenswurdigkeiten.git
cd Sehenswurdigkeiten/Galera/1.Terraform/
terraform fmt && terraform validate
terraform plan
terraform apply
```
**После** выполнения будут созданы 3 ВМ для кластера и 1 ВМ-бастион. 

## 2. Provisioning (настройка кластера через Ansible):
### Шаги выполнение
1. Перейти в директорию с плейбуком:
   ```
   cd Sehenswurdigkeiten/Galera/2.Ansible/ 
   ```
2. 3 приватные адреса 3х ВМ и 1 публичный адрес ВМ-бастиона ручками добавить в  ```hosts.ini```
   ```
   vi hosts.init
   ```
<details>
   <summary>3. Копируем ранее сгенерированный ssh-ключ и ssh-config на машину-бастион (замените в команде IP) для доступа к виртуальным машинам:</summary>

   ```
   tee root_config > /dev/null <<EOF
   Host *
   IdentityFile ~/.ssh/virt
   StrictHostKeyChecking no
   EOF
   chmod 600 root_config
   bastion_ip={{ REPLACE ME }}
   rsync ~/.ssh/virt root@${bastion_ip}:/root/.ssh
   rsync ./root_config root@${bastion_ip}:/root/.ssh/config
   rm -f ./root_config
   ```

</details>

4. Запустить плейбук:
   ```
   ansible-playbook playbook.yml
   ```
<details>
   <summary>5. Создать БД, таблицу, и юзера, с которого будет обращаться к балансировщику:</summary>

   ```
   # Run once on any node:
   MariaDB [demo]> create database demo; use demo;
   MariaDB [demo]> CREATE TABLE users (
     id INT AUTO_INCREMENT PRIMARY KEY,
     name VARCHAR(100) NOT NULL,
     email VARCHAR(100) NOT NULL UNIQUE
   );
   MariaDB [demo]> CREATE USER '<username>'@'%'; 
   MariaDB [demo]> GRANT ALL PRIVILEGES ON demo.users To '<username>'@'%' IDENTIFIED BY '<password>';
   ```

</details>

## 3. Ломаем кластер:
```
# Run once on any node:
MariaDB [demo]> INSERT INTO users (name, email) 
VALUES ('node0', '01@gmail.com'), ('node0', '02@gmail.com'), ('node0', '03@gmail.com');
```
```
# останавливаем репликацию на нодах

# node 2 & 3
sed -i 's/wsrep_on=ON/wsrep_on=OFF/' /etc/mysql/mariadb.conf.d/70-custom.cnf
systemctl restart mysql; mysql demo;

MariaDB [demo]> show global variables like 'wsrep_on'; # expected: OFF
```
```
# Вносим разные записи на всех нодах (email - UNIQUE)

# node 1
INSERT INTO users (name, email) VALUES ('node1', '1@gmail.com'), ('node1', '2@gmail.com'), ('node1', '3@gmail.com')
INSERT INTO users (id, name, email) VALUES (22, 'node1', '5@gmail.com');

# node 2
INSERT INTO users (name, email) VALUES ('node2', '1@gmail.com'), ('node2', '2@gmail.com'), ('node2', '3@gmail.com');
INSERT INTO users (id, name, email) VALUES (22, 'node2', '5@gmail.com');

# node 3
INSERT INTO users (name, email) VALUES ('node3', '1@gmail.com'), ('node3', '2@gmail.com'), ('node3', '3@gmail.com');
INSERT INTO users (id, name, email) VALUES (22, 'node3', '5@gmail.com');
```
```
# Возвращаем репликацию

# node 2 & 3
sed -i 's/wsrep_on=OFF/wsrep_on=ON/' /etc/mysql/mariadb.conf.d/70-custom.cnf
systemctl restart mysql; mysql demo

MariaDB [demo]> show global variables like 'wsrep_on';  # expected: ON
```
#### Итог: node1 нельзя запустить, node 2 & 3 недоступны для чтения и записи:
```
# node 2 & 3

MariaDB [demo]> select * from users;                    # exptected: ERROR 1047 (08S01): WSREP has not yet prepared node for application use
MariaDB [demo]> SHOW STATUS LIKE 'wsrep_cluster%';      # expected: Disconnected

# node 1
systemctl restart mysql                 # expected: Failed to start mariadb.service
```

## 4. Чиним кластер
```
# All nodes (optionally)
cat /var/lib/mysql/grastate.dat

# node 2 &  3
systemctl stop mysql

# node 1
galera_new_cluster

# node 2 &  3
systemctl start mysql
```
#### Итог: все ноды запущены, данные синхронизированны с node1:
```
# All nodes:
cat /var/lib/mysql/grastate.dat;
mysql demo
MariaDB [demo]> SHOW STATUS LIKE 'wsrep_cluster%';       # expected: Primary
```

## 5. Обращение к балансировщику
```
mysql -h <смотри-вывод-терраформа-или-панель-облака> -p 3306 -u <user> -p 

$mysql -h 188.124.51.218 -u poomba demo -e "select * from users;"
+----+-------+--------------+
| id | name  | email        |
+----+-------+--------------+
|  1 | node0 | 01@gmail.com |
|  4 | node0 | 02@gmail.com |
|  7 | node0 | 03@gmail.com |
| 10 | node1 | 1@gmail.com  |
| 11 | node1 | 2@gmail.com  |
| 12 | node1 | 3@gmail.com  |
| 13 | node1 | 4@gmail.com  |
| 22 | node1 | 5@gmail.com  |
+----+-------+--------------+

```