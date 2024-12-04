resource "selectel_vpc_keypair_v2" "keypair_1" {
  name       = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id    = var.service-account-main-id
}

resource "openstack_compute_instance_v2" "nginx1" {
  name              = "nginx1"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = "ru-9a"

  network {
    port = openstack_networking_port_v2.port_1.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_1.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_compute_instance_v2" "nginx2" {
  name              = "nginx2"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = "ru-9a"

  network {
    port = openstack_networking_port_v2.port_2.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_2.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}
