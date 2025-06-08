resource "openstack_compute_instance_v2" "vm" {
  name              = var.hostname
  flavor_id         = var.flavor_id
  key_pair          = var.key_pair
  availability_zone = var.availability_zone
  user_data = file("./metadata/${var.user_data}")

  network {
    port = var.first_port_id
  }

  network {
    port = var.second_port_id
  }

  block_device {
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    volume_size           = var.volume_size
    volume_type           = "fast.${var.availability_zone}"
    uuid                  = var.image_id
  }
}