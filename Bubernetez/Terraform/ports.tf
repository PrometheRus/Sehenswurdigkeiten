module "k8master_ports" {
  source = "../../modules/neutron/port"
  instance_name = "k8master"
  network_id = openstack_networking_network_v2.network_1.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
}

module "k8node1_ports" {
  source = "../../modules/neutron/port"
  instance_name = "k8node1"
  network_id = openstack_networking_network_v2.network_1.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.11"
  second_subnet_ip = "192.168.12.11"
}

module "k8node2_ports" {
  source = "../../modules/neutron/port"
  instance_name = "k8node2"
  network_id = openstack_networking_network_v2.network_1.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.12"
  second_subnet_ip = "192.168.12.12"
}

module "bastion_ports" {
  source = "../../modules/neutron/port"
  instance_name = "bastion"
  network_id = openstack_networking_network_v2.network_1.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.20"
  second_subnet_ip = "192.168.12.20"
}