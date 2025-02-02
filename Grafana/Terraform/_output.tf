output "grafana" {
  value = openstack_networking_floatingip_v2.floating_grafana.address
}

output "docker" {
  value = openstack_networking_floatingip_v2.floating_docker.address
}

output "prometheus" {
  value = openstack_networking_floatingip_v2.floating_prometheus.address
}