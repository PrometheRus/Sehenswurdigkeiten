resource "openstack_networking_port_v2" "port_server_1" {
  name       = "port-server-1"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.11"
  }
}

resource "openstack_networking_port_v2" "port_server_2" {
  name       = "port-server-2"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.12"
  }
}

resource "openstack_networking_port_v2" "port_server_3" {
  name       = "port-server-3"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.13"
  }
}