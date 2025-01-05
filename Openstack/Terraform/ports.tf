resource "openstack_networking_port_v2" "port_1_controller_1" {
  name       = "port1"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.10"
  }
}

resource "openstack_networking_port_v2" "port_2_controller_1" {
  name       = "port2"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.10"
  }
}

resource "openstack_networking_port_v2" "port_1_cmp_node_1" {
  name       = "port1"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.20"
  }
}

resource "openstack_networking_port_v2" "port_2_cmp_node_1" {
  name       = "port2"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.20"
  }
}

resource "openstack_networking_port_v2" "port_1_cmp_node_2" {
  name       = "port1"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.30"
  }
}

resource "openstack_networking_port_v2" "port_2_cmp_node_2" {
  name       = "port2"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.30"
  }
}

resource "openstack_networking_port_v2" "port_1_grafana" {
  name       = "port1_grafana"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.40"
  }
}

resource "openstack_networking_port_v2" "port_2_grafana" {
  name       = "port2_grafana"
  network_id = openstack_networking_network_v2.private_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.40"
  }
}