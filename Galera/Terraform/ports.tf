resource "openstack_networking_port_v2" "port_1" {
  name       = "port1"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.11"
  }
}

resource "openstack_networking_port_v2" "port_2" {
  name       = "port2"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.12"
  }
}

resource "openstack_networking_port_v2" "port_3" {
  name       = "port3"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.13"
  }
}

resource "openstack_networking_port_v2" "port_bastion" {
  name       = "port_bastion"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.20"
  }
}