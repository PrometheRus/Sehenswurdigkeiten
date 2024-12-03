output "public_ip_address_grafana" {
  value = openstack_networking_floatingip_v2.floatingip_1.address
}

output "public_ip_address_prometheus" {
  value = openstack_networking_floatingip_v2.floatingip_1.address
}

output "public_ip_address_nginx" {
  value = openstack_networking_floatingip_v2.floatingip_1.address
}