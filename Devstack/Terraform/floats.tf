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