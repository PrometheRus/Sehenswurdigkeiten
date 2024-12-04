resource "openstack_blockstorage_volume_v3" "volume_1" {
  name                 = "boot-volume-for-server1"
  size                 = var.volume_size
  image_id             = var.image_id
  volume_type          = var.volume_type
  availability_zone    = var.availability_zone
  enable_online_resize = true
}

resource "openstack_blockstorage_volume_v3" "volume_3" {
  name                 = "boot-volume-for-server2"
  size                 = var.volume_size
  image_id             = var.image_id
  volume_type          = var.volume_type
  availability_zone    = var.availability_zone
  enable_online_resize = true
}

resource "openstack_blockstorage_volume_v3" "volume_5" {
  name                 = "boot-volume-for-server2"
  size                 = var.volume_size
  image_id             = var.image_id
  volume_type          = var.volume_type
  availability_zone    = var.availability_zone
  enable_online_resize = true
}

resource "openstack_blockstorage_volume_v3" "volume_7" {
  name                 = "boot-volume-for-server-docker"
  size                 = var.volume_size
  image_id             = var.image_id
  volume_type          = var.volume_type
  availability_zone    = var.availability_zone
  enable_online_resize = true
}