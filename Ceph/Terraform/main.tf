terraform {
  required_providers {
    selectel = {
      source  = "selectel/selectel"
      version = "~> 6.0.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://s3.ru-1.storage.selcloud.ru"
    }
    key    = "terraform/ceph/terraform.tfstate"
    region = "ru-1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}

# Init selectel provider
provider "selectel" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3/"
  domain_name = var.domain
  username    = var.service-account-name
  password    = var.service-account-password
  auth_region = var.auth_region
}

# Init OpenStack provider
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.domain
  tenant_id   = var.project-id
  user_name   = var.service-account-name
  password    = var.service-account-password
  region      = var.auth_region
}