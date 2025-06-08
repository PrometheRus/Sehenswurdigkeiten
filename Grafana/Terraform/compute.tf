module "vm_grafana" {
  source         = "../../modules/nova"
  hostname       = "grafana"
  first_port_id  = module.grafana_ports.first_port_id
  second_port_id = module.grafana_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init_grafana.sh"
}

module "vm_prometheus" {
  source         = "../../modules/nova"
  hostname       = "prometheus"
  first_port_id  = module.prometheus_ports.first_port_id
  second_port_id = module.prometheus_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init_prom.sh"
}

module "vm_docker" {
  source         = "../../modules/nova"
  hostname       = "prometheus"
  first_port_id  = module.docker_ports.first_port_id
  second_port_id = module.docker_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  serviceuser_id = selectel_iam_serviceuser_v1.new_admin.id
  user_data      = "init_prom.sh"
}