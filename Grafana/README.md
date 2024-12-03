##

## Manual


## Automatic
## Manual setup



## Automatic setup:
### Предварительные условия:
1. Подготовить локально Terraform (по [инструкции](https://docs.selectel.ru/terraform/quickstart/))
2. Подготовить локально openstack cli (по [инструкции](https://docs.selectel.ru/en/cloud/servers/tools/openstack/))
3. Создать сервисный аккаунт с ролями:
   1. Администратор аккаунта
   2. Администратор проекта ```<project-name>```
   3. Администратор пользователей
4. Заполнить переменные своими значениями в файле `./1.Terraform/_vars.tf`
   + selectel-domain
   + selectel-project-name
   + selectel-project-id
   + service-account-main-name
   + service-account-main-password
   + service-account-main-id
5. Сгенерировать ssh-ключ, который будет использоваться для доступа к виртуальным машинам:
   ```
   ssh-keyen -t ed25519 -f ~/.ssh/virt
   ```

### Шаги выплонения
1. Развернуть окружение через terraform:
    ```
    cd 1.Terraform && terraform plan
   terraform fmt && terraform validate
   terraform apply
    ```
1. Переходим в директорию с плейбуком:
   ```
   cd ../2.Ansible/ && 
   ```
2. **После** выполнения terraform будут созданы 3 машины по задаче. 3 публичные адреса 3х машин необходимо добавить в инвентори файл ```hosts.ini```
   ```
   vi hosts.init
   ```

Импортировать дашборд 1860