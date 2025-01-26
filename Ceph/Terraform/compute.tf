resource "openstack_compute_instance_v2" "mgr1" {
  name              = "mgr1"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_osd.sh")

  network {
    port = openstack_networking_port_v2.port_1_mgr1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_mgr1.id
  }

  block_device {
    uuid                  = var.image_id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  tags = ["preemptible"]
}

resource "openstack_compute_instance_v2" "osd1" {
  name              = "osd1"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_osd.sh")

  network {
    port = openstack_networking_port_v2.port_1_osd1.id
  }

  network {
    port = openstack_networking_port_v2.port_2_osd1.id
  }

  block_device {
    uuid                  = var.image_id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  block_device {
    volume_size           = var.ceph_volume_size
    source_type           = "blank"
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }

  tags = ["preemptible"]
}

resource "openstack_compute_instance_v2" "osd2" {
  name              = "osd2"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_osd.sh")

  network {
    port = openstack_networking_port_v2.port_1_osd2.id
  }

  network {
    port = openstack_networking_port_v2.port_2_osd2.id
  }

  block_device {
    uuid                  = var.image_id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  block_device {
    volume_size           = var.ceph_volume_size
    source_type           = "blank"
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }

  tags = ["preemptible"]
}

resource "openstack_compute_instance_v2" "osd3" {
  name              = "osd3"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_osd.sh")

  network {
    port = openstack_networking_port_v2.port_1_osd3.id
  }

  network {
    port = openstack_networking_port_v2.port_2_osd3.id
  }

  block_device {
    uuid                  = var.image_id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  block_device {
    volume_size           = var.ceph_volume_size
    source_type           = "blank"
    boot_index            = 1
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "grafana" {
  name              = "srv"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  #user_data         = file("./metadata/init_grafana.sh")


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

  tags = ["preemptible"]
}