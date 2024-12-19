output "private_ip_address_192_168_100_0_devstack_1" {
  value = openstack_networking_port_v2.port_1_devstack_server_1.fixed_ip[0].ip_address
}

output "private_ip_address_192_168_200_0_devstack_1" {
  value = openstack_networking_port_v2.port_2_devstack_server_1.fixed_ip[0].ip_address
}

output "public_ip_address_devstack_1" {
  value = openstack_networking_floatingip_v2.floatingip_devstack_server_1.address
}