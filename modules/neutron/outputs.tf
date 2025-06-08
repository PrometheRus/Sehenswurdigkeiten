# Floats
output "floatingip_id" {
  value = openstack_networking_floatingip_v2.float.id
}

output "floatingip_address" {
  value = openstack_networking_floatingip_v2.float.address
}

# Ports
output "first_port_id" {
  value = openstack_networking_port_v2.port_1.id
}

output "second_port_id" {
  value = openstack_networking_port_v2.port_2.id
}