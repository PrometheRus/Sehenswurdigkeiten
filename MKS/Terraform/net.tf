resource "openstack_networking_network_v2" "network_1" {
  name           = "network-1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet-1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.10.0/24"
}

data "openstack_networking_network_v2" "external_network_1" {
  external = true
  depends_on = [selectel_vpc_project_v2.new_project]
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router"
  external_network_id = data.openstack_networking_network_v2.external_network_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}