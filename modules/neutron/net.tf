resource "openstack_networking_network_v2" "network_1" {
  name           = "network-terraform-${var.project.name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet-1-${var.project.name}"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = var.first_subnet
}

resource "openstack_networking_subnet_v2" "subnet_2" {
  name       = "subnet-2-${var.project.name}"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = var.second_subnet
}

data "openstack_networking_network_v2" "external_network_1" {
  name = "external-network"
  depends_on = [var.project]
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router-${var.project.name}"
  external_network_id = data.openstack_networking_network_v2.external_network_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}