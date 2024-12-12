resource "openstack_networking_port_v2" "port_1_devstack_server_1" {
  name       = "port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_1.id
    ip_address = "192.168.11.10"
  }
}

resource "openstack_networking_port_v2" "port_2_devstack_server_1" {
  name       = "port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
    ip_address = "192.168.12.10"
  }
}


resource "openstack_networking_port_v2" "port_1_devstack_server_2" {
  name       = "port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_1.id
    ip_address = "192.168.11.20"
  }
}

resource "openstack_networking_port_v2" "port_2_devstack_server_2" {
  name       = "port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
    ip_address = "192.168.12.20"
  }
}


resource "openstack_networking_port_v2" "port_1_devstack_server_3" {
  name       = "port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_1.id
    ip_address = "192.168.11.30"
  }
}

resource "openstack_networking_port_v2" "port_2_devstack_server_3" {
  name       = "port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_devstack_2.id
    ip_address = "192.168.12.30"
  }
}