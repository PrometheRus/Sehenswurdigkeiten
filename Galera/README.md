## 1.1. Manual setup of a cluster

## 1.2 Automatic setup of a cluster:
### Предварительные условия:
1. **Ubuntu 24.04.1 LTS**
2. Подготовить локально Terraform (по [инструкции](https://docs.selectel.ru/terraform/quickstart/))
2. Подготовить локально openstack cli (по [инструкции](https://docs.selectel.ru/en/cloud/servers/tools/openstack/))
3. Создать сервисный аккаунт с ролями (по инструкции):
   1. Администратор аккаунта
   2. Администратор проекта ```<project-name>```
   3. Администратор пользователей
4. Заполнить переменные своими значениями в файле `./1.Terraform/_vars.tf`
   + selectel-domain
   + selectel-project-name ??????
   + selectel-project-id
   + service-account-main-name
   + service-account-main-password
   + service-account-main-id
5. Сгенерировать ssh-ключ, который будет использоваться для доступа к виртуальным машинам:
   ```
   ssh-keyen -t ed25519 -f ~/.ssh/virt
   ```

## 2. Шаги выплонения
1. Развернуть окружение через terraform:
    ```
    cd 1.Terraform && terraform plan
   terraform fmt && terraform validate
   terraform apply
    ```
1. Переходим в директорию с плейбуком:
   ```
   cd ../2.Ansible/ 
   ```
2. **После** выполнения terraform будут созданы 3 машины для кластера и 1 машина-бастион. 3 приватные адреса 3х кластерных машин и 1 публичный адрес машины-бастиона необходимо добавить в инвентори файл ```hosts.ini```
   ```
   vi hosts.init
   ```
1. Копируем ранее сгенерированный ssh-ключ и ssh-config на машину-бастион для доступа к виртуальным машинам:
```
tee root_config > /dev/null <<EOF
Host *
 IdentityFile ~/.ssh/virt
 StrictHostKeyChecking no
EOF
chmod 600 root_config
rsync ~/.ssh/virt root@<bastion-ip>:/root/.ssh
rsync ./root_config root@<bastion-ip>:/root/.ssh/config
rm -f ./root_config
```
2. Запускаем плейбук, который настраивает Galera Cluster
   ```
   ansible-playbook playbook.yml
   ```
1. Создаем БД, таблицу, и юзера, с которого будем обращаться к балансировщику:
   ```
   # Run once on any node:
   MariaDB [demo]> create database demo; use demo;
   MariaDB [demo]> CREATE TABLE users (
     id INT AUTO_INCREMENT PRIMARY KEY,
     name VARCHAR(100) NOT NULL,
     email VARCHAR(100) NOT NULL UNIQUE
   );
   MariaDB [demo]> CREATE USER 'poobma'@'%'; 
   MariaDB [demo]> GRANT ALL PRIVILEGES ON demo.users To 'poobma'@'%' IDENTIFIED BY '3Uu918Kb0jswhhT';
   ```

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
MariaDB [demo]> INSERT INTO users (name, email) 
VALUES ('node1', '1@gmail.com'), ('node1', '2@gmail.com'), ('node1', '3@gmail.com');
# node 2
MariaDB [demo]> INSERT INTO users (name, email) 
VALUES ('node2', '1@gmail.com'), ('node2', '2@gmail.com'), ('node2', '3@gmail.com');
# node 3
MariaDB [demo]> INSERT INTO users (name, email) 
VALUES ('node3', '1@gmail.com'), ('node3', '2@gmail.com'), ('node3', '3@gmail.com');
```
```
# Возвращаем репликацию

# node 2 & 3
sed -i 's/wsrep_on=OFF/wsrep_on=ON/' /etc/mysql/mariadb.conf.d/70-custom.cnf
systemctl restart mysql; mysql demo

MariaDB [demo]> show global variables like 'wsrep_on';  # expected: ON
MariaDB [demo]> select * from users;                    # exptected: ERROR 1047 (08S01): WSREP has not yet prepared node for application use
MariaDB [demo]> SHOW STATUS LIKE 'wsrep_cluster%';      # expected: Disconnected
```
```
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

# All nodes:
cat /var/lib/mysql/grastate.dat;
mysql demo
MariaDB [demo]> SHOW STATUS LIKE 'wsrep_cluster%';       # expected: Primary
```
## 5. Обращение к балансировщику
```
mysql -h <смотри-вывод-терраформа> -p 3306 -u poomba -p
```