resource "selectel_vpc_keypair_v2" "keypair_1" {
  name    = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = var.service-account-id
}

resource "openstack_compute_instance_v2" "k8master" {
  name              = "k8master"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/k8.sh")

  network {
    port = openstack_networking_port_v2.port_k8master.id
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

resource "openstack_compute_instance_v2" "k8node1" {
  name              = "k8node1"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/k8.sh")

  network {
    port = openstack_networking_port_v2.port_k8node1.id
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

resource "openstack_compute_instance_v2" "k8node2" {
  name              = "k8node2"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/k8.sh")

  network {
    port = openstack_networking_port_v2.port_k8node2.id
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

resource "openstack_compute_instance_v2" "server_bastion" {
  name              = "bastion"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/bastion.sh")

  network {
    port = openstack_networking_port_v2.port_bastion.id
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