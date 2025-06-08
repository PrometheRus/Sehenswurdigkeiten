resource "openstack_compute_keypair_v2" "k8_keypair" {
  name    = "k8_keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = selectel_iam_serviceuser_v1.new_admin.id
}

module "vm_k8master" {
  source         = "../../modules/nova"
  distro         = var.distro
  hostname       = "k8master"
  keypair        = openstack_compute_keypair_v2.k8_keypair.name
  first_port_id  = module.k8master_ports.first_port_id
  second_port_id = module.k8master_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "k8.sh"
}

module "vm_k8node1" {
  source         = "../../modules/nova"
  distro         = var.distro
  hostname       = "k8node1"
  keypair        = openstack_compute_keypair_v2.k8_keypair.name
  first_port_id  = module.k8node1_ports.first_port_id
  second_port_id = module.k8node1_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "k8.sh"
}

module "vm_k8node2" {
  source         = "../../modules/nova"
  distro         = var.distro
  hostname       = "k8node2"
  keypair        = openstack_compute_keypair_v2.k8_keypair.name
  first_port_id  = module.k8node2_ports.first_port_id
  second_port_id = module.k8node2_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "k8.sh"
}