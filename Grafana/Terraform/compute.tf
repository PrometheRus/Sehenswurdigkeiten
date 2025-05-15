resource "selectel_vpc_keypair_v2" "demo_keypair" {
  name    = "demo_keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = selectel_iam_serviceuser_v1.new_admin.id
}

data "openstack_images_image_v2" "image" {
  name        = "Alma Linux 9 64-bit"
  most_recent = true
  depends_on = [selectel_vpc_project_v2.new_project]
}

resource "openstack_compute_instance_v2" "grafana" {
  name              = "grafana"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_grafana.sh")

  network {
    port = openstack_networking_port_v2.port_grafana.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "prometheus" {
  name              = "prometheus"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_prom.sh")

  network {
    port = openstack_networking_port_v2.port_prometheus.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "docker" {
  name              = "docker"
  flavor_id         = var.flavor_prc
  key_pair          = var.service-ssh-key-name
  availability_zone = var.availability_zone
  user_data         = file("./metadata/init_docker.sh")

  network {
    port = openstack_networking_port_v2.port_docker.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    volume_size           = var.volume_size
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}