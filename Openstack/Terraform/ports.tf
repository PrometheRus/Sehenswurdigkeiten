# Заменить IP на корректные
module "controller_ports" {
  source = "../../modules/neutron/port"
  instance_name = "controller"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
}

module "cmp1_ports" {
  source = "../../modules/neutron/port"
  instance_name = "cmp1"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.20"
  second_subnet_ip = "192.168.12.20"
}

module "cmp2_ports" {
  source = "../../modules/neutron/port"
  instance_name = "cmp2"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.30"
  second_subnet_ip = "192.168.12.30"
}

module "grafana_ports" {
  source = "../../modules/neutron/port"
  instance_name = "grafana"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.40"
  second_subnet_ip = "192.168.12.40"
}

module "rabbitmq_ports" {
  source = "../../modules/neutron/port"
  instance_name = "rabbitmq"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.41"
  second_subnet_ip = "192.168.12.41"
}

module "mysql_ports" {
  source = "../../modules/neutron/port"
  instance_name = "mysql"
  network_id = openstack_networking_network_v2.network_openstack.id
  first_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  second_subnet_id = openstack_networking_subnet_v2.subnet_2.id
  first_subnet_ip = "192.168.11.42"
  second_subnet_ip = "192.168.12.42"
}