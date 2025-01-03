resource "openstack_networking_network_v2" "network_1" {
  name           = "network-1"
  admin_state_up = true
}


resource "openstack_networking_subnet_v2" "subnet_1" {
  name            = "private-subnet-1"
  network_id      = openstack_networking_network_v2.network_1.id
  cidr            = "192.168.11.0/25"
  enable_dhcp     = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]
}

resource "openstack_networking_subnet_v2" "subnet_2" {
  name            = "private-subnet-2"
  network_id      = openstack_networking_network_v2.network_1.id
  cidr            = "192.168.12.0/25"
  enable_dhcp     = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]
}

data "openstack_networking_network_v2" "external_network_1" {
  external = true
}

resource "openstack_networking_router_v2" "router_devstack" {
  name                = "router1"
  external_network_id = data.openstack_networking_network_v2.external_network_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_devstack.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_2" {
  router_id = openstack_networking_router_v2.router_devstack.id
  subnet_id = openstack_networking_subnet_v2.subnet_2.id
}