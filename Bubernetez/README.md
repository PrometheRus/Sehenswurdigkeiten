Someday here will be (maybe) lot's of ve-e-e-e-ry smart writings.

```commandline
tee > vars.tf > /dev/null <<EOF
variable "region" {
  default     = "ru-1"
}
variable "domain" {
  default     = "<domain-id>"
  description = "The id of the user account"
  sensitive   = true
}

variable "service-account-name" {
  default     = "<name>"
  description = "The name of the service account"
  sensitive   = true
}

variable "service-account-password" {
  default     = "<password>"
  description = "The password of the service account"
  sensitive   = true
}

variable "service-account-id" {
  default     = "<account-id>"
  description = "The ID of the service account"
  sensitive   = true
}

variable "project_name" {
  default = "terraform_default_project_name"
}

variable "admin_name" {
  default = "terraform_default_admin_name"
}
EOF
```
```commandline
tee .secrets.tfvars > /dev/null <<EOF
domain = "<domain>"
service-account-name = "<name>"
service-account-password = "<pass>"
service-account-id = "<id>"
EOF

tee .backend.tfvars > /dev/null <<EOF
bucket     = "<container_name>"
access_key = "<access_key>"
secret_key = "<secret_key>"
EOF

terraform init -backend-config=secret.backend.tfvars
terraform plan -var-file=secret.tfvars
terraform apply -var-file=secret.tfvars -auto-approve
```