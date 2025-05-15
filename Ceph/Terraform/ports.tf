module "mgr1_ports" {
  source = "../../modules/neutron/port"
  instance_name = "mgr1"
  network_id = openstack_networking_network_v2.ceph_network.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
}

module "osd1_ports" {
  source = "../../modules/neutron/port"
  instance_name = "osd1"
  network_id = openstack_networking_network_v2.ceph_network.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.11"
  second_subnet_ip = "192.168.12.11"
}

module "osd2_ports" {
  source = "../../modules/neutron/port"
  instance_name = "osd2"
  network_id = openstack_networking_network_v2.ceph_network.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.12"
  second_subnet_ip = "192.168.12.12"
}

module "osd3_ports" {
  source = "../../modules/neutron/port"
  instance_name = "osd3"
  network_id = openstack_networking_network_v2.ceph_network.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.13"
  second_subnet_ip = "192.168.12.13"
}

module "grafana_ports" {
  source = "../../modules/neutron/port"
  instance_name = "grafana"
  network_id = openstack_networking_network_v2.ceph_network.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.20"
  second_subnet_ip = "192.168.12.20"
}