output "mgr1" {
  value = openstack_networking_floatingip_v2.float_mgr1.address
}

output "osd1" {
  value = openstack_networking_floatingip_v2.float_osd1.address
}

output "osd2" {
  value = openstack_networking_floatingip_v2.float_osd2.address
}

output "osd3" {
  value = openstack_networking_floatingip_v2.float_osd3.address
}

output "grafana" {
  value = openstack_networking_floatingip_v2.float_grafana.address
}