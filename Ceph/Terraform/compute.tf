resource "openstack_compute_keypair_v2" "ceph_keypair" {
  name    = "ceph_keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = selectel_iam_serviceuser_v1.new_admin.id
}

module "vm_mgr1" {
  source         = "../../modules/nova"
  hostname       = "mgr1"
  keypair        = openstack_compute_keypair_v2.ceph_keypair.name
  first_port_id  = module.mgr1_ports.first_port_id
  second_port_id = module.mgr1_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "init_osd.sh"
}

module "vm_osd1" {
  source         = "../../modules/nova"
  hostname       = "osd1"
  keypair        = openstack_compute_keypair_v2.ceph_keypair.name
  first_port_id  = module.osd1_ports.first_port_id
  second_port_id = module.osd1_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "init_osd.sh"
}

module "vm_osd2" {
  source         = "../../modules/nova"
  hostname       = "osd2"
  keypair        = openstack_compute_keypair_v2.ceph_keypair.name
  first_port_id  = module.osd2_ports.first_port_id
  second_port_id = module.osd2_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "init_osd.sh"
}

module "vm_osd3" {
  source         = "../../modules/nova"
  hostname       = "osd3"
  keypair        = openstack_compute_keypair_v2.ceph_keypair.name
  first_port_id  = module.osd3_ports.first_port_id
  second_port_id = module.osd3_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "init_osd.sh"
}

module "vm_grafana" {
  source         = "../../modules/nova"
  hostname       = "grafana"
  keypair        = openstack_compute_keypair_v2.ceph_keypair.name
  first_port_id  = module.grafana_ports.first_port_id
  second_port_id = module.grafana_ports.second_port_id
  project        = selectel_vpc_project_v2.new_project
  user_data      = "init_grafana.sh"
}