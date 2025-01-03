output "private_100_devstack_1" {
  value = openstack_networking_port_v2.port_1_devstack_server_1.fixed_ip[0].ip_address
}

output "private_200_devstack_1" {
  value = openstack_networking_port_v2.port_2_devstack_server_1.fixed_ip[0].ip_address
}

output "devstack_1" {
  value = openstack_networking_floatingip_v2.floatingip_devstack_server_1.address
}


output "private_100_devstack_2" {
  value = openstack_networking_port_v2.port_1_devstack_server_2.fixed_ip[0].ip_address
}

output "private_200_devstack_2" {
  value = openstack_networking_port_v2.port_2_devstack_server_2.fixed_ip[0].ip_address
}

output "devstack_2" {
  value = openstack_networking_floatingip_v2.floatingip_devstack_server_2.address
}

output "private_100_devstack_3" {
  value = openstack_networking_port_v2.port_1_devstack_server_3.fixed_ip[0].ip_address
}

output "private_200_devstack_3" {
  value = openstack_networking_port_v2.port_2_devstack_server_3.fixed_ip[0].ip_address
}

output "devstack_3" {
  value = openstack_networking_floatingip_v2.floatingip_devstack_server_3.address
}