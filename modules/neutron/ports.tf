resource "openstack_networking_port_v2" "port_1" {
  name       = "eth0"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = var.first_subnet_ip
  }
}

resource "openstack_networking_port_v2" "port_2" {
  name       = "eth1"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = var.second_subnet_ip
  }
}

resource "openstack_networking_floatingip_v2" "float" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association" {
  port_id     = openstack_networking_port_v2.port_1.id
  floating_ip = openstack_networking_floatingip_v2.float.address
}