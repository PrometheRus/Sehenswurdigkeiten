resource "selectel_vpc_keypair_v2" "keypair_1" {
  name       = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id    = var.service-account-id
}

# Percona + Keystone + Neutron + Octavia + Rabbit
resource "openstack_compute_instance_v2" "controller_1" {
  name              = "controler1"
  flavor_id         = 1015    # SL1.4-16384
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_controller.sh")

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
  user_data         = file("./metadata/init_default.sh")

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
  user_data         = file("./metadata/init_default.sh")

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

resource "openstack_compute_instance_v2" "grafana" {
  name              = "grafana"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_grafana.sh")

  network {
    port = openstack_networking_port_v2.port_1_grafana.id
  }

  network {
    port = openstack_networking_port_v2.port_2_grafana.id
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