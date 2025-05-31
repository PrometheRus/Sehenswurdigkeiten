resource "openstack_networking_network_v2" "ceph_network" {
  name           = "ceph-network"
  admin_state_up = true
}


resource "openstack_networking_subnet_v2" "subnet_1" {
  name            = "subnet-1"
  network_id      = openstack_networking_network_v2.ceph_network.id
  cidr            = "192.168.11.0/25"
  enable_dhcp     = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]
}

resource "openstack_networking_subnet_v2" "subnet_2" {
  name            = "ceph-subnet"
  network_id      = openstack_networking_network_v2.ceph_network.id
  cidr            = "192.168.12.0/25"
  no_gateway      = true
  enable_dhcp     = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]
}

data "openstack_networking_network_v2" "external_ceph_network" {
  external = true
  depends_on = [selectel_vpc_project_v2.new_project]
}

resource "openstack_networking_router_v2" "ceph_router" {
  name                = "ceph-router"
  external_network_id = data.openstack_networking_network_v2.external_ceph_network.id
}

resource "openstack_networking_router_interface_v2" "ceph_router_interface" {
  router_id = openstack_networking_router_v2.ceph_router.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}