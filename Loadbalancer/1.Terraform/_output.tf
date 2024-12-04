output "private_ip_address_1" {
  value = openstack_compute_instance_v2.server_1.access_ip_v4
}

output "private_ip_address_2" {
  value = openstack_compute_instance_v2.server_2.access_ip_v4
}

output "private_ip_address_3" {
  value = openstack_compute_instance_v2.server_3.access_ip_v4
}

output "public_ip_address_bastion" {
  value = openstack_networking_floatingip_v2.floating_bastion.address
}

output "public_ip_address_lb" {
  value = openstack_networking_floatingip_v2.floatingip_lb.address
}