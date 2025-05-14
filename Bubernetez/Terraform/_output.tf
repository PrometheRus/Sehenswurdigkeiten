output "server_1" {
  value = openstack_compute_instance_v2.server_1.access_ip_v4
}

output "server_2" {
  value = openstack_compute_instance_v2.server_2.access_ip_v4
}

output "server_3" {
  value = openstack_compute_instance_v2.server_3.access_ip_v4
}

output "bastion_private" {
  value = openstack_compute_instance_v2.server_bastion.access_ip_v4
}

output "bastion" {
  value = openstack_networking_floatingip_v2.floating_bastion.address
}