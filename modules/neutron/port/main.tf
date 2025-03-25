resource "openstack_networking_port_v2" "port_1" {
  name       = "${var.instance_name}-eth0"
  network_id = var.network_id

  fixed_ip {
    subnet_id  = var.first_subnet_id
    ip_address = var.first_subnet_ip
  }
}
resource "openstack_networking_port_v2" "port_2" {
  name       = "${var.instance_name}-eth1"
  network_id = var.network_id

  fixed_ip {
    subnet_id  = var.second_subnet_id
    ip_address = var.second_subnet_ip
  }
}