resource "openstack_networking_port_v2" "port_k8master" {
  name       = "port-port_k8master"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.11"
  }
}

resource "openstack_networking_port_v2" "port_k8node1" {
  name       = "port-k8node1"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.12"
  }
}

resource "openstack_networking_port_v2" "port_k8node2" {
  name       = "port-k8node2"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.13"
  }
}

resource "openstack_networking_port_v2" "port_bastion" {
  name       = "port-bastion"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.10.20"
  }
}