# MKS

## 0. Prerequisites:
#### Ваши креды сервисного аккаунта и прочая добавить в директорию Terraform:
```commandline
tee Terraform/.secrets.tfvars > /dev/null << EOF
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
tee Terraform/.backend.tfvars > /dev/null << EOF
bucket     = "<bucket>"
access_key = "<key>"
secret_key = "<key>"
EOF
```

## 1. Deployment

```commandline
cd Terraform/
terraform init -backend-config=.backend.tfvars
terraform plan -var-file=.secrets.tfvars

# Если все ок:
terraform apply -var-file=ssecrets.tfvars -auto-approve
```
После выполнения будет создан кластер MKS