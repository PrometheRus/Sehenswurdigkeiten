output "private_controller_100" {
  value = openstack_networking_port_v2.port_1_controller_1.fixed_ip[0].ip_address
}

output "private_controller_200" {
  value = openstack_networking_port_v2.port_2_controller_1.fixed_ip[0].ip_address
}

output "public_controller" {
  value = openstack_networking_floatingip_v2.floatingip_controoller.address
}


output "private_cmp1_100" {
  value = openstack_networking_port_v2.port_1_cmp_node_1.fixed_ip[0].ip_address
}

output "private_cmp1_200" {
  value = openstack_networking_port_v2.port_2_cmp_node_1.fixed_ip[0].ip_address
}

output "public_cmp1" {
  value = openstack_networking_floatingip_v2.floatingip_cmp1.address
}


output "private_cmp2_100" {
  value = openstack_networking_port_v2.port_1_cmp_node_2.fixed_ip[0].ip_address
}

output "private_cmp2_200" {
  value = openstack_networking_port_v2.port_2_cmp_node_2.fixed_ip[0].ip_address
}

output "public_cmp2" {
  value = openstack_networking_floatingip_v2.floatingip_cmp2.address
}

output "private_keystone_100" {
  value = openstack_networking_port_v2.port_1_cmp_node_2.fixed_ip[0].ip_address
}

output "private_keystone_200" {
  value = openstack_networking_port_v2.port_2_cmp_node_2.fixed_ip[0].ip_address
}

output "public_keystone" {
  value = openstack_networking_floatingip_v2.floatingip_keystone.address
}