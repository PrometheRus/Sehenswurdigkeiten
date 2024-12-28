resource "selectel_vpc_keypair_v2" "keypair_1" {
  name       = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id    = var.service-account-id
}

resource "openstack_compute_instance_v2" "controller_1" {
  name              = "controler1"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init.yml")

  network {
    port = openstack_networking_port_v2.port_1_controller_1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_controller_1.id
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

resource "openstack_compute_instance_v2" "cmp_node_1" {
  name              = "cmp1"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init.yml")

  network {
    port = openstack_networking_port_v2.port_1_cmp_node_1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_cmp_node_1.id
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

resource "openstack_compute_instance_v2" "cmp_node_2" {
  name              = "cmp2"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init.yml")

  network {
    port = openstack_networking_port_v2.port_1_cmp_node_2.id
  }

  network {
    port = openstack_networking_port_v2.port_2_cmp_node_2.id
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

resource "openstack_compute_instance_v2" "keystone" {
  name              = "keystone"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init.yml")

  network {
    port = openstack_networking_port_v2.port_1_keystone.id
  }

  network {
    port = openstack_networking_port_v2.port_2_keystone.id
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