resource "selectel_vpc_keypair_v2" "keypair_1" {
  name    = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = var.service-account-id
}

resource "openstack_compute_instance_v2" "server_1" {
  name              = "server1"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/init.sh")

  network {
    port = openstack_networking_port_v2.port_server_1.id
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

resource "openstack_compute_instance_v2" "server_2" {
  name              = "server2"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/init.sh")

  network {
    port = openstack_networking_port_v2.port_server_2.id
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

resource "openstack_compute_instance_v2" "server_3" {
  name              = "server3"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/init.sh")

  network {
    port = openstack_networking_port_v2.port_server_3.id
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