resource "openstack_networking_port_v2" "port_1_mgr1" {
  name       = "mgr1-port-internet"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.20"
  }
}

resource "openstack_networking_port_v2" "port_2_mgr1" {
  name       = "mgr1-port-internal"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.20"
  }
}

resource "openstack_networking_port_v2" "port_1_osd1" {
  name       = "osd1-port-internet"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.21"
  }
}

resource "openstack_networking_port_v2" "port_2_osd1" {
  name       = "osd1-port-internal"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.21"
  }
}

resource "openstack_networking_port_v2" "port_1_osd2" {
  name       = "osd2-port-internet"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.22"
  }
}

resource "openstack_networking_port_v2" "port_2_osd2" {
  name       = "osd2-port-internal"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.22"
  }
}

resource "openstack_networking_port_v2" "port_1_osd3" {
  name       = "osd3-port-internet"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.23"
  }
}

resource "openstack_networking_port_v2" "port_2_osd3" {
  name       = "osd3-port-internal"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_2.id
    ip_address = "192.168.12.23"
  }
}

resource "openstack_networking_port_v2" "port_1_grafana" {
  name       = "grafana-port-internet"
  network_id = openstack_networking_network_v2.ceph_network.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
    ip_address = "192.168.11.40"
  }
}