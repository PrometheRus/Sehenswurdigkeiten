resource "selectel_vpc_keypair_v2" "demo_keypair" {
  name    = "demo_keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = selectel_iam_serviceuser_v1.new_admin.id
}

module "vm_controller" {
  source         = "../../modules/nova"
  distro         = var.distro
  hostname       = "controller"
  keypair        = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.controller_ports.first_port_id
  second_port_id = module.controller_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init_controller.sh"
}

module "vm_cmp1" {
  source         = "../../modules/nova"
  distro         = var.distro
  hostname       = "cmp1"
  keypair        = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.cmp1_ports.first_port_id
  second_port_id = module.cmp1_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init_cmp.sh"
}

module "vm_cmp2" {
  source         = "../../modules/nova"
  distro         = var.distro
  hostname       = "cmp1"
  keypair        = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.cmp1_ports.first_port_id
  second_port_id = module.cmp1_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init_cmp.sh"
}