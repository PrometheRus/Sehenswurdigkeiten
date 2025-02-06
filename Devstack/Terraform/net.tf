resource "openstack_networking_network_v2" "network_devstack" {
  name           = "network-devstack"
  region         = var.auth_region
  admin_state_up = true
}


resource "openstack_networking_subnet_v2" "subnet_1" {
  name        = "subnet-openstack-1"
  network_id  = openstack_networking_network_v2.network_devstack.id
  cidr        = "192.168.11.0/25"
  enable_dhcp = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]
}

resource "openstack_networking_subnet_v2" "subnet_2" {
  name        = "subnet-openstack-2"
  network_id  = openstack_networking_network_v2.network_devstack.id
  cidr        = "192.168.12.0/25"
  no_gateway  = true
  enable_dhcp = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]

}

data "openstack_networking_network_v2" "external_private_network" {
  external = true
}

resource "openstack_networking_router_v2" "router" {
  name                = "router1"
  external_network_id = data.openstack_networking_network_v2.external_private_network.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

# FIREWALL
module "firewall_rules" {
  source = "../../modules/neutron/fw"
  router_interface_id = openstack_networking_router_interface_v2.router_interface_1.port_id
}