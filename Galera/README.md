```
ip=$(terraform -chdir=/home/prometherus/Projects/Sehenswurdigkeiten/Galera/Terraform output -raw bastion)
ssh root@${ip}
```

### Запустить руками systemctl start mysql@bootstrap.service

# XtraDB Cluster (AlmaLinux)

<details>
  <summary>Предварительные условия</summary>

   1. Создать сервисный аккаунт (по инструкции) с ролями:
      1. ``Администратор <project-name>``
      2. ``Администратор пользователей``
   2. Подготовить локально Terraform (по [инструкции](https://docs.selectel.ru/terraform/quickstart/))
   3. Заполнить переменные Terraform **своими** значениями в файле `./1.Terraform/_secrets.tf`
      - domain
      - project-id
      - service-account-name
      - service-account-password
      - service-account-id
</details>
<details>
  <summary>Пример файла _secerts.tf</summary>

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

### Deployment via Terraform:

```
git clone git@github.com:PrometheRus/Sehenswurdigkeiten.git
cd Sehenswurdigkeiten/Galera/Terraform/
terraform fmt && terraform validate
terraform plan
terraform apply
```
После выполнения будут созданы 3 ВМ БД кластера и 1 ВМ-бастион

### Наполнить БД
```
# Заходим на ноду:
ip=$(terraform -chdir=/home/prometherus/Projects/Sehenswurdigkeiten/Galera/Terraform output -raw bastion)
ssh -J root@${ip} root@192.168.10.11

# или на рута
ssh root@${ip}
```
### Break up the cluster:
```
# Run once on any node:
INSERT INTO users (name, email) 
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

### Чиним кластер
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

### Обращение к балансировщику
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