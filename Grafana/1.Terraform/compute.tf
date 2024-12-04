resource "selectel_vpc_keypair_v2" "keypair_1" {
  name    = "keypair"
  public_key = file("~/.ssh/virt.pub")
  user_id = var.service-account-main-id
}

resource "openstack_compute_instance_v2" "grafana" {
  name              = "grafana"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_grafana.id
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

resource "openstack_compute_instance_v2" "prometheus" {
  name              = "prometheus"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_prometheus.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_3.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_compute_instance_v2" "nginx" {
  name              = "nginx"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_nginx.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_5.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_compute_instance_v2" "docker" {
  name              = "docker"
  flavor_id         = var.flavor_id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_docker.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_7.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}