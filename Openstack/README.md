#### Что нужно добавить в Terraform, чтобы использовать этот мануал:
##### Ваши секреты сервисного аккаунта и прочая:
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
##### Ваши секреты объектного хранилища для сохранения terraform.state:
```commandline
tee ./secret.backend.tfvars > /dev/null << EOF
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

```commandline
ssh root@$(terraform output -raw controller)
ssh root@$(terraform output -raw grafana)
ssh root@$(terraform output -raw cmp1)
ssh root@$(terraform output -raw cmp2)
ssh root@$(terraform output -raw rabbitmq)
ssh root@$(terraform output -raw stat)
ssh root@$(terraform output -raw mysql)
```