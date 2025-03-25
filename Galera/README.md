# XtraDB Cluster (AlmaLinux)

## 0. Prerequisites:
#### Ваши креды сервисного аккаунта и прочая добавить в директорию Terraform:
```commandline
tee ./secret.tfvars > /dev/null << EOF
domain                          = "<domain>"
project-id                      = "<project-id>"
project-name                    = "<project-name>"
service-ssh-key-name            = "<name>"

# Existing service account for Selectel provider
service-account-name            = "<project-admin-service-account-name>"
service-account-password        = "<pass>"
service-account-id              = "<id>"

# New service account for Openstack provider
temp-service-account-name       = "<temp-service-account-name>"
temp-service-account-password   = "<temp-service-account-pass>"
EOF
```
#### Ваши секреты объектного хранилища для сохранения ```terraform.state``` удаленно (либо удалите полностью блок ```backend``` из ```main.tf``` - в этом случае state будет сохранен только локально):
```commandline
tee ./secret.backend.tfvars > /dev/null << EOF
bucket     = "<bucket>"
access_key = "<key>"
secret_key = "<key>"
EOF
```

## 1. Deployment

```commandline
cd Sehenswurdigkeiten/Galera/Terraform/
terraform init -backend-config=secret.backend.tfvars
terraform plan -var-file=secret.tfvars

# Если все ок:
terraform apply -var-file=secret.tfvars -auto-approve
```
После выполнения будут созданы 3 ноды кластера

### Наполнить БД
```
ssh root@$(terraform output -raw first_float)

$mysql >
INSERT INTO users (name, email) 
VALUES ('node0', '01@gmail.com'), ('node0', '02@gmail.com'), ('node0', '03@gmail.com');
```
### Break down the cluster:
```
# останавливаем репликацию на нодах

# node 2 & 3
sed -i 's/wsrep_on=ON/wsrep_on=OFF/' /etc/my.cnf
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
sed -i 's/wsrep_on=OFF/wsrep_on=ON/' /etc/my.cnf
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