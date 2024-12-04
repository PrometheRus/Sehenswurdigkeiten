output "private_ip_address_prometheus" {
  value = openstack_compute_instance_v2.prometheus.access_ip_v4
}

output "private_ip_address_nginx" {
  value = openstack_compute_instance_v2.nginx.access_ip_v4
}

output "private_ip_address_grafana" {
  value = openstack_compute_instance_v2.grafana.access_ip_v4
}

output "public_ip_address_grafana" {
  value = openstack_networking_floatingip_v2.floatingip_grafana.address
}

output "private_ip_address_docker" {
  value = openstack_compute_instance_v2.docker.access_ip_v4
}

output "public_ip_address_docker" {
  value = openstack_networking_floatingip_v2.floatingip_docker.address
}