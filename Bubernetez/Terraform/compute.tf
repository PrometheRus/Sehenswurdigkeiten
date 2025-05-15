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

module "vm_k8master" {

  hostname       = "k8master"
  image_id       = data.openstack_images_image_v2.image.id
  key_pair       = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.k8master_ports.first_port_id
  second_port_id = module.k8master_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "k8.sh"
}

module "vm_k8node1" {
  hostname       = "k8node1"
  image_id       = data.openstack_images_image_v2.image.id
  key_pair       = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.k8node2_ports.first_port_id
  second_port_id = module.k8node1_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "k8.sh"
}

module "vm_k8node2" {
  hostname       = "k8node2"
  image_id       = data.openstack_images_image_v2.image.id
  key_pair       = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.k8node2_ports.first_port_id
  second_port_id = module.k8node2_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "k8.sh"
}

module "vm_bastion" {
  hostname       = "k8node2"
  image_id       = data.openstack_images_image_v2.image.id
  key_pair       = selectel_vpc_keypair_v2.demo_keypair.name
  first_port_id  = module.k8node2_ports.first_port_id
  second_port_id = module.k8node2_ports.second_port_id
  source         = "../../modules/nova/compute"
  user_data      = "bastion.sh"
}