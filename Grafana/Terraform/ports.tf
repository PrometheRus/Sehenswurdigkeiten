resource "openstack_networking_port_v2" "port_grafana" {
  name       = "port_grafana"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.199.71"
  }
}

resource "openstack_networking_port_v2" "port_prometheus" {
  name       = "port_prometheus"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.199.72"
  }
}

resource "openstack_networking_port_v2" "port_docker" {
  name       = "port_docker"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.199.73"
  }
}