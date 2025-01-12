output "private_100_controller" {
  value = openstack_networking_port_v2.port_1_controller.fixed_ip[0].ip_address
}

output "private_200_controller" {
  value = openstack_networking_port_v2.port_2_controller.fixed_ip[0].ip_address
}

output "controller" {
  value = openstack_networking_floatingip_v2.float_controller.address
}


output "private_100_cmp1" {
  value = openstack_networking_port_v2.port_1_cmp1.fixed_ip[0].ip_address
}

output "private_200_cmp1" {
  value = openstack_networking_port_v2.port_2_cmp1.fixed_ip[0].ip_address
}

output "cmp1" {
  value = openstack_networking_floatingip_v2.float_cmp1.address
}


output "private_100_cmp2" {
  value = openstack_networking_port_v2.port_1_cmp2.fixed_ip[0].ip_address
}

output "private_200_cmp2" {
  value = openstack_networking_port_v2.port_2_cmp2.fixed_ip[0].ip_address
}

output "cmp2" {
  value = openstack_networking_floatingip_v2.float_cmp2.address
}