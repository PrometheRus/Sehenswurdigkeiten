output "first_port_id" {
  value = openstack_networking_port_v2.port_1.id
}

output "second_port_id" {
  value = openstack_networking_port_v2.port_2.id
}