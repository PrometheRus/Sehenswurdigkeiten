resource "openstack_networking_floatingip_v2" "controller" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "cmp1" {
  pool = "external-network"
  depends_on = [openstack_compute_instance_v2.cmp1]
}

resource "openstack_networking_floatingip_v2" "cmp2" {
  pool = "external-network"
  depends_on = [openstack_compute_instance_v2.cmp2]
}


resource "openstack_networking_floatingip_associate_v2" "association_controller" {
  port_id     = openstack_networking_port_v2.port_1_controller.id
  floating_ip = openstack_networking_floatingip_v2.controller.address
}

resource "openstack_networking_floatingip_associate_v2" "association_cmp1" {
  port_id     = openstack_networking_port_v2.port_1_cmp1.id
  floating_ip = openstack_networking_floatingip_v2.cmp1.address
  depends_on = [openstack_compute_instance_v2.cmp1]
}

resource "openstack_networking_floatingip_associate_v2" "association_cmp2" {
  port_id     = openstack_networking_port_v2.port_1_cmp2.id
  floating_ip = openstack_networking_floatingip_v2.cmp2.address
  depends_on = [openstack_compute_instance_v2.cmp2]
}