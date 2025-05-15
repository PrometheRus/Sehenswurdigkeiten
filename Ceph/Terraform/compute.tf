data "openstack_images_image_v2" "image" {
  name        = "Alma Linux 9 64-bit"
  most_recent = true
  depends_on  = [selectel_vpc_project_v2.new_project]
}

resource "selectel_vpc_keypair_v2" "demo_keypair" {
  name    = "demo_keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = selectel_iam_serviceuser_v1.new_admin.id
}

module "vm_mgr1" {
  hostname       = "mgr1"
  image_id       = data.openstack_images_image_v2.image
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.mgr1_ports.first_port_id
  second_port_id = module.mgr1_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "init_osd.sh"
}

module "vm_osd1" {
  hostname       = "osd1"
  image_id       = data.openstack_images_image_v2.image
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.osd1_ports.first_port_id
  second_port_id = module.osd1_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "init_osd.sh"
}

module "vm_osd2" {
  hostname       = "osd2"
  image_id       = data.openstack_images_image_v2.image
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.osd2_ports.first_port_id
  second_port_id = module.osd2_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "init_osd.sh"
}

module "vm_osd3" {
  hostname       = "osd2"
  image_id       = data.openstack_images_image_v2.image
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.osd3_ports.first_port_id
  second_port_id = module.osd3_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "init_osd.sh"
}

module "vm_grafana" {
  hostname       = "grafana"
  image_id       = data.openstack_images_image_v2.image
  key_pair       = selectel_vpc_keypair_v2.demo_keypair
  first_port_id  = module.grafana_ports.first_port_id
  second_port_id = module.grafana_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "init_grafana.sh"
}
