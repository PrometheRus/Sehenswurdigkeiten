module "k8master_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.10"
  second_subnet_ip = "192.168.12.10"
  project = selectel_vpc_project_v2.new_project
}

module "k8node1_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.11"
  second_subnet_ip = "192.168.12.11"
  project = selectel_vpc_project_v2.new_project
}

module "k8node2_ports" {
  source = "../../modules/neutron"
  first_subnet_ip = "192.168.11.12"
  second_subnet_ip = "192.168.12.12"
  project = selectel_vpc_project_v2.new_project
}