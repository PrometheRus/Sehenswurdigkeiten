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
}

# Init selectel provider
provider "selectel" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3/"
  domain_name = var.domain
  username    = var.service-account-name
  password    = var.service-account-password
  auth_region = "ru-9"
}

# Init OpenStack provider
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.domain
  tenant_id   = var.project-id
  user_name   = var.service-account-name
  password    = var.service-account-password
  region      = "ru-9"
}