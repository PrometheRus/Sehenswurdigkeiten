resource "openstack_compute_instance_v2" "vm" {
  name              = var.hostname
  flavor_id         = var.flavor_id
  key_pair          = var.key_pair
  availability_zone = var.availability_zone
  user_data         = file("./metadata/${var.user_data}")

  network {
    port = var.first_port_id
  }

  network {
    port = var.second_port_id
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