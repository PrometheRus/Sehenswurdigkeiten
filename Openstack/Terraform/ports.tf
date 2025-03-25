# Заменить IP на корректные

module "controller_ports" {
  source = "../../modules/neutron/port"
  instance_name = "controller"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.30"
  second_subnet_ip = "192.168.12.30"
}

module "cmp1_ports" {
  source = "../../modules/neutron/port"
  instance_name = "cmp1"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.31"
  second_subnet_ip = "192.168.12.31"
}

module "cmp2_ports" {
  source = "../../modules/neutron/port"
  instance_name = "cmp2"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.32"
  second_subnet_ip = "192.168.12.32"
}

module "grafana_ports" {
  source = "../../modules/neutron/port"
  instance_name = "grafana"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.33"
  second_subnet_ip = "192.168.12.33"
}

module "rabbitmq_ports" {
  source = "../../modules/neutron/port"
  instance_name = "rabbitmq"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.34"
  second_subnet_ip = "192.168.12.34"
}

module "stat_ports" {
  source = "../../modules/neutron/port"
  instance_name = "stat"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.35"
  second_subnet_ip = "192.168.12.35"
}

module "mysql_ports" {
  source = "../../modules/neutron/port"
  instance_name = "mysql"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.36"
  second_subnet_ip = "192.168.12.36"
}

module "gw_ports" {
  source = "../../modules/neutron/port"
  instance_name = "gw"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.37"
  second_subnet_ip = "192.168.12.37"
}