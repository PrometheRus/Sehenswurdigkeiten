resource "selectel_vpc_keypair_v2" "keypair_1" {
  name    = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = var.service-account-id
}

resource "openstack_compute_instance_v2" "devstack_server_1" {
  name              = "devstack_1"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/init.yml")

  network {
    port = openstack_networking_port_v2.port_1_devstack_server_1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_devstack_server_1.id
  }

  block_device {
    uuid                  = var.image_id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

# resource "openstack_compute_instance_v2" "devstack_server_2" {
#   name              = "devstack_2"
#   flavor_id         = var.flavor_id
#   key_pair          = selectel_vpc_keypair_v2.keypair_1.name
#   availability_zone = var.availability_zone
#   user_data = file("./metadata/init.yml")
#
#   network {
#     port = openstack_networking_port_v2.port_1_devstack_server_2.id
#   }
#
#   network {
#     port = openstack_networking_port_v2.port_2_devstack_server_2.id
#   }
#
#   block_device {
#     uuid                  = var.image_id
#     volume_size           = var.volume_size
#     source_type           = "image"
#     boot_index            = 0
#     destination_type      = "volume"
#     delete_on_termination = true
#   }
# }
#
# resource "openstack_compute_instance_v2" "devstack_server_3" {
#   name              = "devstack_3"
#   flavor_id         = var.flavor_id
#   key_pair          = selectel_vpc_keypair_v2.keypair_1.name
#   availability_zone = var.availability_zone
#   user_data = file("./metadata/init.yml")
#
#   network {
#     port = openstack_networking_port_v2.port_1_devstack_server_3.id
#   }
#
#   network {
#     port = openstack_networking_port_v2.port_2_devstack_server_3.id
#   }
#
#   block_device {
#     uuid                  = var.image_id
#     volume_size           = var.volume_size
#     source_type           = "image"
#     boot_index            = 0
#     destination_type      = "volume"
#     delete_on_termination = true
#   }
# }

