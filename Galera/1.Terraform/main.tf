terraform {
  required_providers {
    selectel = {
      source  = "selectel/selectel"
      version = "5.4.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
  }
}

# Init selectel provider
provider "selectel" {
  domain_name = var.selectel-domain
  username    = var.service-account-main-name
  password    = var.service-account-main-password
}

# # Create a service account for a Selectel
# resource "selectel_iam_serviceuser_v1" "serviceuser_selectel" {
#   name     = var.service-account-main-name
#   password = var.service-account-main-password
#   role {
#     role_name  = "member"
#     scope      = "project"
#     project_id = selectel_vpc_project_v2.project_1.id
#   }
#   role {
#     role_name  = "member"
#     scope      = "account"
#   }
#   role {
#     role_name  = "iam_admin"
#     scope      = "account"
#   }
# }

# Init OpenStack provider
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.selectel-domain
  tenant_id   = var.selectel-project-id
  user_name   = var.service-account-main-name
  password    = var.service-account-main-password
  region      = "ru-9"
}