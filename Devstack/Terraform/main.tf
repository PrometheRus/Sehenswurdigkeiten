terraform {
  required_providers {
    selectel = {
      source  = "selectel/selectel"
      version = "~> 6.5.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.1.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://s3.ru-1.storage.selcloud.ru"
    }
    key    = "terraform/devstack/terraform.tfstate"
    region = "ru-1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}

# Init selectel provider
provider "selectel" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3/"
  domain_name = var.domain
  username    = var.service-account-name
  password    = var.service-account-password
  auth_region = var.region
}

resource "selectel_vpc_project_v2" "new_project" {
  name = "temporary-${var.project_name}-project"
}

resource "random_password" "password" {
  length      = 20
  special     = true
  min_upper   = 3
  min_lower   = 3
  min_numeric = 3
  min_special = 3
}

resource "selectel_iam_serviceuser_v1" "new_admin" {
  name     = "temporary-${var.project_name}-admin"
  password = random_password.password.result
  role {
    role_name  = "member"
    scope      = "project"
    project_id = selectel_vpc_project_v2.new_project.id
  }
}

# Init OpenStack provider
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.domain
  tenant_id   = selectel_vpc_project_v2.new_project.id
  user_name   = selectel_iam_serviceuser_v1.new_admin.name
  password    = selectel_iam_serviceuser_v1.new_admin.password
  region      = var.region
}