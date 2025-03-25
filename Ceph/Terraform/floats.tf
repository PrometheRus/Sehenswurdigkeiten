resource "openstack_networking_floatingip_v2" "float_mgr1" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "float_osd1" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "float_osd2" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "float_osd3" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_v2" "float_grafana" {
  pool = "external-network"
}



resource "openstack_networking_floatingip_associate_v2" "association_mgr1" {
  port_id     = openstack_networking_port_v2.port_1_mgr1.id
  floating_ip = openstack_networking_floatingip_v2.float_mgr1.address
}

resource "openstack_networking_floatingip_associate_v2" "association_osd1" {
  port_id     = openstack_networking_port_v2.port_1_osd1.id
  floating_ip = openstack_networking_floatingip_v2.float_osd1.address
}

resource "openstack_networking_floatingip_associate_v2" "association_osd2" {
  port_id     = openstack_networking_port_v2.port_1_osd2.id
  floating_ip = openstack_networking_floatingip_v2.float_osd2.address
}

resource "openstack_networking_floatingip_associate_v2" "association_osd3" {
  port_id     = openstack_networking_port_v2.port_1_osd3.id
  floating_ip = openstack_networking_floatingip_v2.float_osd3.address
}

resource "openstack_networking_floatingip_associate_v2" "association_grafana" {
  port_id     = openstack_networking_port_v2.port_1_grafana.id
  floating_ip = openstack_networking_floatingip_v2.float_grafana.address
}
