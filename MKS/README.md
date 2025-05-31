# MKS

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
cd Sehenswurdigkeiten/MKS/Terraform/
terraform init -backend-config=secret.backend.tfvars
terraform plan -var-file=secret.tfvars

# Если все ок:
terraform apply -var-file=secret.tfvars -auto-approve
```
После выполнения будет создан кластер MKS