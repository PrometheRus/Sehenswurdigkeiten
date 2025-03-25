output "first" {
  value = openstack_compute_instance_v2.server_1.access_ip_v4
}

output "second" {
  value = openstack_compute_instance_v2.server_2.access_ip_v4
}

output "third" {
  value = openstack_compute_instance_v2.server_3.access_ip_v4
}

output "first_float" {
  value = openstack_networking_floatingip_v2.float_first.address
}

output "second_float" {
  value = openstack_networking_floatingip_v2.float_second.address
}

output "third_float" {
  value = openstack_networking_floatingip_v2.float_third.address
}