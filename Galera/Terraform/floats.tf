resource "openstack_networking_floatingip_v2" "float_first" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_first" {
  port_id     = openstack_networking_port_v2.port_server_1.id
  floating_ip = openstack_networking_floatingip_v2.float_first.address
}

resource "openstack_networking_floatingip_v2" "float_second" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_second" {
  port_id     = openstack_networking_port_v2.port_server_2.id
  floating_ip = openstack_networking_floatingip_v2.float_second.address
}

resource "openstack_networking_floatingip_v2" "float_third" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_third" {
  port_id     = openstack_networking_port_v2.port_server_3.id
  floating_ip = openstack_networking_floatingip_v2.float_third.address
}