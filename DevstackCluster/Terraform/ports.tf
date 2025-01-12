resource "openstack_networking_port_v2" "port_1_controller" {
  name       = "controller-port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.10"
  }
}

resource "openstack_networking_port_v2" "port_2_controller" {
  name       = "controller-port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.10"
  }
}

resource "openstack_networking_port_v2" "port_1_cmp1" {
  name       = "cmp1-port1-internet"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.11"
  }
}

resource "openstack_networking_port_v2" "port_2_cmp1" {
  name       = "cmp1-port2-ovs"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.11"
  }
}


resource "openstack_networking_port_v2" "port_1_cmp2" {
  name       = "cmp2-port1"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.12"
  }
}

resource "openstack_networking_port_v2" "port_2_cmp2" {
  name       = "cmp2-port2"
  network_id = openstack_networking_network_v2.network_devstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.12"
  }
}