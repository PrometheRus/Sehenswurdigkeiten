module "vm_controller" {
  source         = "../../modules/nova/compute"
  hostname       = "controller"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.controller_ports.first_port_id
  second_port_id = module.controller_ports.second_port_id
  user_data      = "init_controller.sh"
  flavor_id      = var.flavor_id
  image_id       = var.image_id
}

module "vm_cmp1" {
  source         = "../../modules/nova/compute"
  hostname       = "cmp1"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.cmp1_ports.first_port_id
  second_port_id = module.cmp1_ports.second_port_id
  user_data      = "init_cmp.sh"
  flavor_id      = var.flavor_id
  image_id       = var.image_id
}

module "vm_cmp2" {
  source         = "../../modules/nova/compute"
  hostname       = "cmp2"
  key_pair       = var.service-ssh-key-name
  first_port_id  = module.cmp2_ports.first_port_id
  second_port_id = module.cmp2_ports.second_port_id
  user_data      = "init_cmp.sh"
  flavor_id      = var.flavor_id
  image_id       = var.image_id
}