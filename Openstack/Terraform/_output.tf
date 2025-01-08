output "controller_100" {
  value = openstack_networking_port_v2.port_1_controller.fixed_ip[0].ip_address
}

output "controller_200" {
  value = openstack_networking_port_v2.port_2_controller.fixed_ip[0].ip_address
}

output "controller" {
  value = openstack_networking_floatingip_v2.floatingip_controoller.address
}


output "cmp1_100" {
  value = openstack_networking_port_v2.port_1_cmp1.fixed_ip[0].ip_address
}

output "cmp1_200" {
  value = openstack_networking_port_v2.port_2_cmp1.fixed_ip[0].ip_address
}

output "cmp1" {
  value = openstack_networking_floatingip_v2.floatingip_cmp1.address
}


output "cmp2_100" {
  value = openstack_networking_port_v2.port_1_cmp2.fixed_ip[0].ip_address
}

output "cmp2_200" {
  value = openstack_networking_port_v2.port_2_cmp2.fixed_ip[0].ip_address
}

output "cmp2" {
  value = openstack_networking_floatingip_v2.floatingip_cmp2.address
}


output "grafana_100" {
  value = openstack_networking_port_v2.port_1_grafana.fixed_ip[0].ip_address
}

output "grafana" {
  value = openstack_networking_floatingip_v2.floatingip_grafana.address
}


# SRV
output "srv_100" {
  value = openstack_networking_port_v2.port_1_srv.fixed_ip[0].ip_address
}

output "srv_200" {
  value = openstack_networking_port_v2.port_2_srv.fixed_ip[0].ip_address
}

output "srv" {
  value = openstack_networking_floatingip_v2.floatingip_srv.address
}