resource "openstack_networking_network_v2" "network_1" {
  name           = "private-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
}

data "openstack_networking_network_v2" "external_network_1" {
  external = true
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router"
  external_network_id = data.openstack_networking_network_v2.external_network_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}


resource "openstack_networking_port_v2" "port_1" {
  name       = "port"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

resource "openstack_networking_port_v2" "port_2" {
  name       = "port"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

resource "openstack_networking_port_v2" "port_3" {
  name       = "port"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

resource "openstack_networking_port_v2" "port_bastion" {
  name       = "port"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

# # Assign a PUBLIC IP for the instance 1
# resource "openstack_networking_floatingip_v2" "floatingip_1" {
#   pool = "external-network"
# }
#
# resource "openstack_networking_floatingip_associate_v2" "association_1" {
#   port_id     = openstack_networking_port_v2.port_1.id
#   floating_ip = openstack_networking_floatingip_v2.floatingip_1.address
# }
#
#
# # Assign a PUBLIC IP for the instance 2
# resource "openstack_networking_floatingip_v2" "floatingip_2" {
#   pool = "external-network"
# }
#
# resource "openstack_networking_floatingip_associate_v2" "association_2" {
#   port_id     = openstack_networking_port_v2.port_2.id
#   floating_ip = openstack_networking_floatingip_v2.floatingip_2.address
# }
#
#
# # Assign a PUBLIC IP for the instance 3
# resource "openstack_networking_floatingip_v2" "floatingip_3" {
#   pool = "external-network"
# }
#
# resource "openstack_networking_floatingip_associate_v2" "association_3" {
#   port_id     = openstack_networking_port_v2.port_3.id
#   floating_ip = openstack_networking_floatingip_v2.floatingip_3.address
# }

resource "openstack_networking_floatingip_v2" "floatingip_lb" {
  pool    = "external-network"
  port_id = openstack_lb_loadbalancer_v2.load_balancer_1.vip_port_id
}


# Assign a PUBLIC IP for the 'Bastion' instance
resource "openstack_networking_floatingip_v2" "floating_bastion" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_bastion" {
  port_id     = openstack_networking_port_v2.port_bastion.id
  floating_ip = openstack_networking_floatingip_v2.floating_bastion.address
}