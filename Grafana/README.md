## Grafana + Prometheus + Node exporter на **Alma Linux 9 64-bit**

#### Что нужно добавить в Terraform, чтобы использовать этот мануал:
##### Ваши секреты сервисного аккаунта и прочая:
```commandline
tee Sehenswurdigkeiten/Grafana/Terraform/secret.tfvars > << EOF
domain                   = "<domain>"
project-id               = "<project-id>"
service-account-name     = "<project-admin-service-account-name>"
service-account-password = "<pass>"
service-account-id       = "<id>"
service-ssh-key-name     = "<name>"
EOF
```
##### Ваши секреты объектного хранилища для сохранения terraform.state:
```commandline
tee Sehenswurdigkeiten/Grafana/Terraform/secret.backend.tfvars > << EOF
bucket     = "<bucket>"
access_key = "<key>"
secret_key = "<key>"
EOF
```

## 1. Deployment via Terraform:

```commandline
cd Sehenswurdigkeiten/Grafana/Terraform/
terraform init -backend-config=secret.backend.tfvars
terraform apply -var-file=secret.tfvars -auto-approve
```

Будут созданы 3 ВМ
```commandline
ssh root@$(terraform output -raw grafana)
ssh root@$(terraform output -raw prometheus)
ssh root@$(terraform output -raw docker)

# Опционально
ssh root@$(terraform output -raw docker)
cd docker
docker compose --file docker-compose-web.yml -p nginx up -d
sleep 5s;
docker compose --file docker-compose-web.yml -p nginx ps
```


### Настроить дашборд:
   1. Переходим на публичный адрес машины **grafana** ``<IP-address>:3000``, логинимся под ``admin:admin``, устанавливаем новый админский пароль
   2. В разделе **/dashboards** импортируем дашборд **1860**

**Результат: доступен дашборд с системными метриками с возможностью выбора из 3х машин**

## 2. Deployment via Docker:
```
ssh root@$(terraform output -raw docker) 
cd observability
docker compose --file docker-compose-observability.yml -p observability up -d
sleep 5s;
docker compose --file docker-compose-observability.yml -p observability ps -a

# docker compose --file docker-compose-observability.yml -p observability down

seq 1 500 | xargs -P5 -I{} curl http://188.124.51.185:8880/
```
Проверяем в браузере по ``<public_ip_address_docker>:3000``, что Grafana в контейнере поднялась и импортируем ручками дашборд **14282**

### По итогу развернуты контейнеры:
1. prometheus
2. grafana
3. cadvisor
4. lb + 3 nginx (это "отсебятина", чтобы наполнить графики).

### Сетевая изоляция контейнеров:
1. grafana в одной подсети с prometheus
2. cadvisor в одной подсети с prometheus
3. lb & nginx-{1..3} в отдельной подсети

#### _Изоляция контейнеров на уровне user namespace НЕ реализована, так как cadvisor должен иметь доступ к хостовому namespace_.

**Результат: доступен дашборд с системными метриками с возможностью выбора из 7ми контейнеров**