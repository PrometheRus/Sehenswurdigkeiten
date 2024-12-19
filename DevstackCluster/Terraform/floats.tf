resource "openstack_networking_floatingip_v2" "floatingip_devstack_server_1" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_devstack_1" {
  port_id     = openstack_networking_port_v2.port_1_devstack_server_1.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_devstack_server_1.address
}

resource "openstack_networking_floatingip_v2" "floatingip_devstack_server_2" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_devstack_2" {
  port_id     = openstack_networking_port_v2.port_1_devstack_server_2.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_devstack_server_2.address
}

resource "openstack_networking_floatingip_v2" "floatingip_devstack_server_3" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_devstack_3" {
  port_id     = openstack_networking_port_v2.port_1_devstack_server_3.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_devstack_server_3.address
}

resource "openstack_networking_floatingip_v2" "floatingip_devstack_server_nfs" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_devstack_nfs" {
  port_id     = openstack_networking_port_v2.port_1_devstack_server_nfs.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_devstack_server_nfs.address
}