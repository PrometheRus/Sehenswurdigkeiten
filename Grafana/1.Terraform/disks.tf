data "openstack_images_image_v2" "image_1" {
  name        = "Ubuntu 24.04 LTS 64-bit"
  most_recent = true
  visibility  = "public"
}

resource "openstack_blockstorage_volume_v3" "volume_1" {
  name                 = "boot-volume-for-server"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.image_1.id
  volume_type          = "fast.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "volume_2" {
  name                 = "additional-volume-for-server"
  size                 = "10"
  volume_type          = "universal.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true
}

resource "openstack_blockstorage_volume_v3" "volume_3" {
  name                 = "boot-volume-for-server"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.image_1.id
  volume_type          = "fast.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "volume_4" {
  name                 = "additional-volume-for-server"
  size                 = "10"
  volume_type          = "universal.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true
}

resource "openstack_blockstorage_volume_v3" "volume_5" {
  name                 = "boot-volume-for-server"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.image_1.id
  volume_type          = "fast.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "volume_6" {
  name                 = "additional-volume-for-server"
  size                 = "10"
  volume_type          = "universal.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true
}

resource "openstack_blockstorage_volume_v3" "volume_7" {
  name                 = "boot-volume-for-server"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.image_1.id
  volume_type          = "fast.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "volume_8" {
  name                 = "additional-volume-for-server"
  size                 = "10"
  volume_type          = "universal.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true
}