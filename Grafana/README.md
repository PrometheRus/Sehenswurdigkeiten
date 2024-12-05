# Grafana + Prometheus + Node exporter на **Ubuntu 24.04 LTS**
## 1.1. Manual deployment (openstack cli)
Развернул аналогично задаче по [Galera Cluster](https://github.com/PrometheRus/Sehenswurdigkeiten/tree/main/Galera#11-manual-deployment-openstack-cli) (только без балансировщика), каких то особых нюансов нет. Дублировать информацию не вижу целесообразным.

## 1.2 Automatic deployment (Terraform):
### Предварительные шаги:
1. Аналогично задаче по [Galera Cluster](https://github.com/PrometheRus/Sehenswurdigkeiten/tree/main/Galera#предварительные-шаги) 

### Шаги выполнения:
   ```
   git clone git@github.com:PrometheRus/Sehenswurdigkeiten.git
   cd Sehenswurdigkeiten/Grafana/1.Terraform/
   terraform fmt && terraform validate
   terraform plan
   terraform apply
   ```
    
**После** выполнения будут созданы 4 ВМ. В выводе команды будут указаные приватные (4 шт) и публичные (2 шт) адреса машин.

## 2. Provisioning (настройка кластера через Ansible):
### Предварительные шаги:
1. Установить anisble-core
### Шаги выполнение
2. Перейти в директорию с плейбуком:
   ```
   cd Sehenswurdigkeiten/Grafana/2.Ansible/ 
   ```
3. 3 приватные адреса и 2 публичные адреса ручками добавить в  ```hosts.ini```
   ```
   vi hosts.init
   ```
4. Копируем ранее сгенерированный ssh-ключ и ssh-config на машину-бастион (замените в команде IP) для доступа к виртуальным машинам:
```
tee root_config > /dev/null <<EOF
Host *
 IdentityFile ~/.ssh/virt
 StrictHostKeyChecking no
EOF
chmod 600 root_config
bastion_ip={{ REPLACE ME }}
rsync ~/.ssh/virt root@"${bastion_ip}":/root/.ssh
rsync ./root_config root@"${bastion_ip}":/root/.ssh/config
rm -f ./root_config
```
5. Запустить плейбук:
   ```
   ansible-playbook playbook.yml
   ```
6. Настроить дашборд:
   1. Переходим на публичный адрес машины **grafana** ``<IP-address>:3000``, логинимся под ``admin:admin``, устанавливаем новый админский пароль
   2. В разделе **/dashboards** импортируем дашборд **1860**

**Результат: доступен дашборд с системными метриками с возможностью выбора из 3х машин**
![img.png](img.png)

### Моя графана доступна по [ссылке](http://87.228.27.130:3000/d/rYdddlPWk/node-exporter-full). Креды: **viewer:viewer**, доступ из под 188.93.16.0/22 (могу открыть еще при необходимости)

## 3. Docker-compose:
В пунктах **1.2** и **2** Терраформ уже развернул машину **docker**, ansible перекинул файлы, и установил пакеты. Дополнительные действия по подготовке не требуются.

### Как поднять контейнеры:
1. Заходим по **ssh** на машину ``<public_ip_address_docker>`` и запускаем:
```
docker compose -p demo up
...

# Проверяем, что все "бегит"
root@docker:~# docker compose -p demo ps
NAME                IMAGE                      COMMAND                  SERVICE      CREATED         STATUS                   PORTS
demo-cadvisor-1     gcr.io/cadvisor/cadvisor   "/usr/bin/cadvisor -…"   cadvisor     6 minutes ago   Up 6 minutes (healthy)   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp
demo-grafana-1      grafana/grafana            "/run.sh"                grafana      6 minutes ago   Up 6 minutes             0.0.0.0:3000->3000/tcp, :::3000->3000/tcp
demo-lb-1           nginx                      "/docker-entrypoint.…"   lb           6 minutes ago   Up 6 minutes             80/tcp, 0.0.0.0:8888->8888/tcp, :::8888->8888/tcp
demo-nginx-1        nginx                      "/docker-entrypoint.…"   nginx        6 minutes ago   Up 6 minutes             80/tcp
demo-nginx-2        nginx                      "/docker-entrypoint.…"   nginx        6 minutes ago   Up 6 minutes             80/tcp
demo-nginx-3        nginx                      "/docker-entrypoint.…"   nginx        6 minutes ago   Up 6 minutes             80/tcp
demo-prometheus-1   prom/prometheus            "/bin/prometheus --c…"   prometheus   6 minutes ago   Up 6 minutes             0.0.0.0:9090->9090/tcp, :::9090->9090/tcp
```
2. Проверяем в браузере по ``<public_ip_address_docker>:3000``, что Grafana поднялась
3. Импортируем ручками дашборд **14282**

### По итогу развернуты контейнеры:
1. prometheus
2. grafana
3. cadvisor
4. lb + 3 nginx (это "отсебятина", чтобы наполнить графики).

### Сетевая изоляция контейнеров (4 подсети):
1. grafana в подсети с prometheus
2. cadvisor в подсети с prometheus
3. lb & nginx-{1..3} в отдельной подсети

### Изоляция контейнеров на уровне user namespace НЕ реализована, так как cadvisor должен иметь доступ к хостовому namespoce. Как это обойти, используя Docker Compose, я не нашел решения.

**Результат: доступен дашборд с системными метриками с возможностью выбора из 7ми контейнеров**
![img_2.png](img_2.png)