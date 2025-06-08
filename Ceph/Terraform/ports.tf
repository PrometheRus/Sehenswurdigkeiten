module "mgr1_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
  project = selectel_vpc_project_v2.new_project
}


module "osd1_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.11"
  second_subnet_ip = "192.168.12.11"
  project = selectel_vpc_project_v2.new_project
}

module "osd2_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.12"
  second_subnet_ip = "192.168.12.12"
  project = selectel_vpc_project_v2.new_project
}

module "osd3_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.13"
  second_subnet_ip = "192.168.12.13"
  project = selectel_vpc_project_v2.new_project
}

module "grafana_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.14"
  second_subnet_ip = "192.168.12.14"
  project = selectel_vpc_project_v2.new_project
}