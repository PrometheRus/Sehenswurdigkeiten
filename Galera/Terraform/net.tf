module "server_1_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
  project = selectel_vpc_project_v2.new_project
}

module "server_2_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.11"
  second_subnet_ip = "192.168.12.11"
  project = selectel_vpc_project_v2.new_project
}

module "server_3_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.12"
  second_subnet_ip = "192.168.12.12"
  project = selectel_vpc_project_v2.new_project
}