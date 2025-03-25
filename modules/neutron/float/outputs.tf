output "floatingip_id" {
  value = openstack_networking_floatingip_v2.float.id
}

output "floatingip_address" {
  value = openstack_networking_floatingip_v2.float.address
}