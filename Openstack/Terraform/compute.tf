# Percona + Keystone + Neutron + Octavia
resource "openstack_compute_instance_v2" "controller" {
  name              = "controller"
  flavor_id         = var.flavor_ctrl
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_controller.sh")

  network {
    port = openstack_networking_port_v2.port_1_controller.id
  }

  network {
    port = openstack_networking_port_v2.port_2_controller.id
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

resource "openstack_compute_instance_v2" "cmp_1" {
  name              = "cmp1"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_cmp.sh")

  network {
    port = openstack_networking_port_v2.port_1_cmp1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_cmp1.id
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

resource "openstack_compute_instance_v2" "cmp_2" {
  name              = "cmp2"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_cmp.sh")

  network {
    port = openstack_networking_port_v2.port_1_cmp2.id
  }

  network {
    port = openstack_networking_port_v2.port_2_cmp2.id
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
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_grafana.sh")

  network {
    port = openstack_networking_port_v2.port_1_grafana.id
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

# Rabbit
resource "openstack_compute_instance_v2" "srv" {
  name              = "srv"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_srv.sh")

  network {
    port = openstack_networking_port_v2.port_1_srv.id
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