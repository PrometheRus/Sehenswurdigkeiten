output "private_ip_address_devstack_1" {
  value = openstack_compute_instance_v2.devstack_server_1.access_ip_v4
}

output "public_ip_address_devstack_1" {
  value = openstack_networking_floatingip_v2.floatingip_devstack_server_1.address
}

output "private_ip_address_devstack_2" {
  value = openstack_compute_instance_v2.devstack_server_2.access_ip_v4
}

output "public_ip_address_devstack_2" {
  value = openstack_networking_floatingip_v2.floatingip_devstack_server_2.address
}