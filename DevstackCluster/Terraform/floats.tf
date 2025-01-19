resource "openstack_networking_floatingip_v2" "controller" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "cmp1" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "cmp2" {
  pool = "external-network"
}


resource "openstack_networking_floatingip_associate_v2" "association_controller" {
  port_id     = openstack_networking_port_v2.controller_1.id
  floating_ip = openstack_networking_floatingip_v2.controller.address
}

resource "openstack_networking_floatingip_associate_v2" "association_cmp1" {
  port_id     = openstack_networking_port_v2.port_1_cmp1.id
  floating_ip = openstack_networking_floatingip_v2.cmp1.address
}

resource "openstack_networking_floatingip_associate_v2" "association_cmp2" {
  port_id     = openstack_networking_port_v2.port_1_cmp2.id
  floating_ip = openstack_networking_floatingip_v2.cmp2.address
}