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

# Init OpenStack provider
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.selectel-domain
  tenant_id   = var.selectel-project-id
  user_name   = var.service-account-main-name
  password    = var.service-account-main-password
  region      = "ru-9"
}