# Percona + Keystone + Neutron + Octavia
module "vm_controller" {
  source         = "../../modules/nova/compute"
  hostname       = "controller"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.controller_ports.first_port_id
  second_port_id = module.controller_ports.second_port_id
  user_data      = "init_controller.sh"
  flavor_id      = var.flavor_id
}

module "vm_cmp1" {
  source         = "../../modules/nova/compute"
  hostname       = "cmp1"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.cmp1_ports.first_port_id
  second_port_id = module.cmp1_ports.second_port_id
  user_data      = "init_cmp.sh"
}

module "vm_cmp2" {
  source         = "../../modules/nova/compute"
  hostname       = "cmp2"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.cmp2_ports.first_port_id
  second_port_id = module.cmp2_ports.second_port_id
  user_data      = "init_cmp.sh"
}

module "vm_grafana" {
  source         = "../../modules/nova/compute"
  hostname       = "grafana"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.grafana_ports.first_port_id
  second_port_id = module.grafana_ports.second_port_id
  user_data      = "init_grafana.sh"
}

module "vm_rabbitmq" {
  source         = "../../modules/nova/compute"
  hostname       = "rabbitmq"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.rabbitmq_ports.first_port_id
  second_port_id = module.rabbitmq_ports.second_port_id
  user_data      = "init_rabbitmq.sh"
}

module "vm_stat" {
  source         = "../../modules/nova/compute"
  hostname       = "stat"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.stat_ports.first_port_id
  second_port_id = module.stat_ports.second_port_id
  user_data      = "init_stat.sh"
}

module "vm_mysql" {
  source         = "../../modules/nova/compute"
  hostname       = "mysql"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.mysql_ports.first_port_id
  second_port_id = module.mysql_ports.second_port_id
  user_data      = "init_mysql.sh"
}

module "vm_gw" {
  source         = "../../modules/nova/compute"
  hostname       = "gw"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.gw_ports.first_port_id
  second_port_id = module.gw_ports.second_port_id
  user_data      = "init_gw.sh"
}