resource "openstack_networking_port_v2" "port_1_controller" {
  name       = "controller-port-internet"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.10"
  }
}

resource "openstack_networking_port_v2" "port_2_controller" {
  name       = "controller-port-ovs"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.10"
  }
}

resource "openstack_networking_port_v2" "port_1_cmp1" {
  name       = "cmp1-port-internet"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.20"
  }
}

resource "openstack_networking_port_v2" "port_2_cmp1" {
  name       = "cmp1-port-ovs"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.20"
  }
}

resource "openstack_networking_port_v2" "port_1_cmp2" {
  name       = "cmp2-port-internet"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.30"
  }
}

resource "openstack_networking_port_v2" "port_2_cmp2" {
  name       = "cmp2-port-ovs"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.30"
  }
}

resource "openstack_networking_port_v2" "port_1_grafana" {
  name       = "grafana-port-internet"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.40"
  }
}

# SRV
resource "openstack_networking_port_v2" "port_1_srv" {
  name       = "srv-port-internet"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.41"
  }
}

resource "openstack_networking_port_v2" "port_2_srv" {
  name       = "srv-port-ovs"
  network_id = openstack_networking_network_v2.network_openstack.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.41"
  }
}