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

  network {
    port = openstack_networking_port_v2.port_1_devstack_server_1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_devstack_server_1.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_devstack_server_1.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_compute_instance_v2" "devstack_server_2" {
  name              = "devstack_2"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_1_devstack_server_2.id
  }

  network {
    port = openstack_networking_port_v2.port_2_devstack_server_2.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_devstack_server_2.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_compute_instance_v2" "devstack_server_3" {
  name              = "devstack_3"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_1_devstack_server_3.id
  }

  network {
    port = openstack_networking_port_v2.port_2_devstack_server_3.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_devstack_server_3.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

