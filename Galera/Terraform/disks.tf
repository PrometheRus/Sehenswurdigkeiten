# resource "openstack_blockstorage_volume_v3" "volume_1" {
#   name                 = "boot-volume-server1"
#   size                 = var.volume_size
#   image_id             = var.image_id
#   volume_type          = var.volume_type
#   availability_zone    = var.availability_zone
#   enable_online_resize = true
# }
#
# resource "openstack_blockstorage_volume_v3" "volume_2" {
#   name                 = "boot-volume-server2"
#   size                 = var.volume_size
#   image_id             = var.image_id
#   volume_type          = var.volume_type
#   availability_zone    = var.availability_zone
#   enable_online_resize = true
# }
#
# resource "openstack_blockstorage_volume_v3" "volume_3" {
#   name                 = "boot-volume-server3"
#   size                 = var.volume_size
#   image_id             = var.image_id
#   volume_type          = var.volume_type
#   availability_zone    = var.availability_zone
#   enable_online_resize = true
# }
#
# resource "openstack_blockstorage_volume_v3" "volume_4" {
#   name                 = "boot-volume-bastion"
#   size                 = var.volume_size
#   image_id             = var.image_id
#   volume_type          = var.volume_type
#   availability_zone    = var.availability_zone
#   enable_online_resize = true
# }