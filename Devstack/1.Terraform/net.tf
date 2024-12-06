resource "openstack_networking_network_v2" "network_devstack" {
  name           = "private-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_devstack_1" {
  name       = "private-subnet-1"
  network_id = openstack_networking_network_v2.network_devstack.id
  cidr       = "192.168.100.0/27"
}

resource "openstack_networking_subnet_v2" "subnet_devstack_2" {
  name       = "private-subnet-2"
  network_id = openstack_networking_network_v2.network_devstack.id
  cidr       = "192.168.200.0/27"
}

data "openstack_networking_network_v2" "external_network_devstack" {
  external = true
}

resource "openstack_networking_router_v2" "router_devstack" {
  name                = "router"
  external_network_id = data.openstack_networking_network_v2.external_network_devstack.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_devstack.id
  subnet_id = openstack_networking_subnet_v2.subnet_devstack_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_2" {
  router_id = openstack_networking_router_v2.router_devstack.id
  subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
}

resource "openstack_networking_port_v2" "port_1_devstack_server_1" {
  name       = "port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_1.id
  }
}

resource "openstack_networking_port_v2" "port_2_devstack_server_1" {
  name       = "port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
  }
}

resource "openstack_networking_port_v2" "port_1_devstack_server_2" {
  name       = "port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
  }
}

resource "openstack_networking_port_v2" "port_2_devstack_server_2" {
  name       = "port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
  }
}

# Assign a PUBLIC IP for the Devstack Instance 1
resource "openstack_networking_floatingip_v2" "floatingip_devstack_server_1" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_devstack_1" {
  port_id     = openstack_networking_port_v2.port_1_devstack_server_1.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_devstack_server_1.address
}

# Assign a PUBLIC IP for the Devstack Instance 2
resource "openstack_networking_floatingip_v2" "floatingip_devstack_server_2" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_devstack_2" {
  port_id     = openstack_networking_port_v2.port_1_devstack_server_2.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_devstack_server_2.address
}