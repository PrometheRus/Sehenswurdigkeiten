module "vm_server_1" {
  source         = "../../modules/nova"
  hostname       = "server_1"
  first_port_id  = module.server_1_ports.first_port_id
  second_port_id = module.server_1_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init.sh"
}

module "vm_server_2" {
  source         = "../../modules/nova"
  hostname       = "server_2"
  first_port_id  = module.server_2_ports.first_port_id
  second_port_id = module.server_2_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init.sh"
}

module "vm_server_3" {
  source         = "../../modules/nova"
  hostname       = "server_3"
  first_port_id  = module.server_3_ports.first_port_id
  second_port_id = module.server_3_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init.sh"
}