module "float_controller" {
  source = "../../modules/neutron/float"
  port_id = module.controller_ports.first_port_id
}

module "float_cmp1" {
  source = "../../modules/neutron/float"
  port_id = module.cmp1_ports.first_port_id
}

module "float_cmp2" {
  source = "../../modules/neutron/float"
  port_id = module.cmp2_ports.first_port_id
}

module "float_grafana" {
  source = "../../modules/neutron/float"
  port_id = module.grafana_ports.first_port_id
}

module "float_rabbitmq" {
  source = "../../modules/neutron/float"
  port_id = module.rabbitmq_ports.first_port_id
}

module "float_stat" {
  source = "../../modules/neutron/float"
  port_id = module.stat_ports.first_port_id
}

module "float_mysql" {
  source = "../../modules/neutron/float"
  port_id = module.mysql_ports.first_port_id
}

module "float_gw" {
  source = "../../modules/neutron/float"
  port_id = module.gw_ports.first_port_id
}