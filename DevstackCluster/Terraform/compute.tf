resource "selectel_vpc_keypair_v2" "keypair_devstack" {
  name    = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = var.service-account-id
}

resource "openstack_compute_instance_v2" "controller" {
  name              = "controller"
  flavor_id         = var.flavor_ctrl
  key_pair          = selectel_vpc_keypair_v2.keypair_devstack.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/controller.sh")

  network {
    port = openstack_networking_port_v2.controller_1.id
  }

  network {
    port = openstack_networking_port_v2.controller_2.id
  }

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    guest_format          = "ext4"
    source_type           = "image"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    uuid                  = var.image_id
  }
}

resource "openstack_compute_instance_v2" "cmp1" {
  name              = "cmp1"
  flavor_id         = var.flavor_prc
  key_pair          = selectel_vpc_keypair_v2.keypair_devstack.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/compute.sh")
  count             = var.enable_resource ? 1 : 0 # Temporary disable deployment

  network {
    port = openstack_networking_port_v2.port_1_cmp1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_cmp1.id
  }

  block_device {
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    uuid                  = var.image_id
  }
}

resource "openstack_compute_instance_v2" "cmp2" {
  name              = "cmp2"
  flavor_id         = var.flavor_prc
  key_pair          = selectel_vpc_keypair_v2.keypair_devstack.name
  availability_zone = var.availability_zone
  user_data = file("./metadata/compute.sh")
  count             = var.enable_resource ? 1 : 0 # Temporary disable deployment

  network {
    port = openstack_networking_port_v2.port_1_cmp2.id
  }

  network {
    port = openstack_networking_port_v2.port_2_cmp2.id
  }

  block_device {
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    uuid                  = var.image_id
  }
}