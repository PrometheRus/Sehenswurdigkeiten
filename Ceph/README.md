```commandline
ssh root@$(terraform output --raw osd1)
```

```commandline
tee secret.tfvars > /dev/null <<EOF
domain = "<domain>"
project-id = "<id>"
service-account-name = "<name>"
service-account-password = "<pass>"
service-account-id = "<id>"
service-ssh-key-name = "<name>"
EOF

tee secret.backend.tfvars > /dev/null <<EOF
bucket     = "<container_name>"
access_key = "<access_key>"
secret_key = "<secret_key>"
EOF

terraform init -backend-config=secret.backend.tfvars
terraform plan -var-file=secret.tfvars
terraform apply -var-file=secret.tfvars -auto-approve
```