output "controller" {
  value = openstack_networking_floatingip_v2.controller.address
}

output "cmp1" {
  value = openstack_networking_floatingip_v2.cmp1.address
}

output "cmp2" {
  value = openstack_networking_floatingip_v2.cmp2.address
}