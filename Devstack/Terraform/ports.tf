module "controller_ports" {
  source = "../../modules/neutron/port"
  instance_name = "controller"
  network_id = openstack_networking_network_v2.network_devstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
}

module "cmp1_ports" {
  source = "../../modules/neutron/port"
  instance_name = "cmp1"
  network_id = openstack_networking_network_v2.network_devstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.11"
  second_subnet_ip = "192.168.12.11"
}

module "cmp2_ports" {
  source = "../../modules/neutron/port"
  instance_name = "cmp2"
  network_id = openstack_networking_network_v2.network_devstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.12"
  second_subnet_ip = "192.168.12.12"
}