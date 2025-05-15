resource "selectel_vpc_keypair_v2" "demo_keypair" {
  name    = "demo_keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = selectel_iam_serviceuser_v1.new_admin.id
}

module "vm_controller" {
  source         = "../../modules/nova/compute"
  hostname       = "controller"
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.controller_ports.first_port_id
  second_port_id = module.controller_ports.second_port_id
  user_data      = "init_controller.sh"
  flavor_id      = var.flavor_id
  project        = selectel_vpc_project_v2.new_project
}

module "vm_cmp1" {
  source         = "../../modules/nova/compute"
  hostname       = "cmp1"
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.cmp1_ports.first_port_id
  second_port_id = module.cmp1_ports.second_port_id
  user_data      = "init_cmp.sh"
  flavor_id      = var.flavor_id
  project        = selectel_vpc_project_v2.new_project
}

module "vm_cmp2" {
  source         = "../../modules/nova/compute"
  hostname       = "cmp2"
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.cmp2_ports.first_port_id
  second_port_id = module.cmp2_ports.second_port_id
  user_data      = "init_cmp.sh"
  flavor_id      = var.flavor_id
  project        = selectel_vpc_project_v2.new_project
}