data "openstack_images_image_v2" "image" {
  name        = var.distro
  most_recent = true
  depends_on = [var.project]
}

data "openstack_compute_flavor_v2" "flavor" {
  name = "PRC20.4-8192"
  depends_on = [var.project]
}



resource "openstack_compute_instance_v2" "vm" {
  name              = var.hostname
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  key_pair          = var.keypair
  availability_zone = "${var.region}a"
  user_data = file("./metadata/${var.user_data}")


  network {
    port = "${var.first_port_id}"
  }

  network {
    port = "${var.second_port_id}"
  }

  block_device {
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    volume_size           = var.volume_size
    volume_type           = "fast.${var.region}a"
    uuid                  = data.openstack_images_image_v2.image.id
  }
}