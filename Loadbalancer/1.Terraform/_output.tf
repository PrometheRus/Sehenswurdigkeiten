output "private_ip_address_1" {
  value = openstack_compute_instance_v2.nginx1.access_ip_v4
}

output "private_ip_address_2" {
  value = openstack_compute_instance_v2.nginx2.access_ip_v4
}

output "public_ip_address_nginx1" {
  value = openstack_networking_floatingip_v2.floating_nginx1.address
}

output "public_ip_address_nginx2" {
  value = openstack_networking_floatingip_v2.floating_nginx2.address
}