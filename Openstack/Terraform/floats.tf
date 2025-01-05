resource "openstack_networking_floatingip_v2" "floatingip_controoller" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_controller" {
  port_id     = openstack_networking_port_v2.port_2_controller_1.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_controoller.address
}

resource "openstack_networking_floatingip_v2" "floatingip_cmp1" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_cmp_1" {
  port_id     = openstack_networking_port_v2.port_2_cmp_node_1.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_cmp1.address
}

resource "openstack_networking_floatingip_v2" "floatingip_cmp2" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_cmp_2" {
  port_id     = openstack_networking_port_v2.port_2_cmp_node_2.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_cmp2.address
}

resource "openstack_networking_floatingip_v2" "floatingip_grafana" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_grafana" {
  port_id     = openstack_networking_port_v2.port_2_grafana.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_grafana.address
}