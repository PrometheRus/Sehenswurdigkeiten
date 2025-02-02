# Grafana
resource "openstack_networking_floatingip_v2" "floating_grafana" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_1" {
  port_id     = openstack_networking_port_v2.port_grafana.id
  floating_ip = openstack_networking_floatingip_v2.floating_grafana.address
}

# Docker
resource "openstack_networking_floatingip_v2" "floating_docker" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_2" {
  port_id     = openstack_networking_port_v2.port_docker.id
  floating_ip = openstack_networking_floatingip_v2.floating_docker.address
}

# Prometheus
resource "openstack_networking_floatingip_v2" "floating_prometheus" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_3" {
  port_id     = openstack_networking_port_v2.port_prometheus.id
  floating_ip = openstack_networking_floatingip_v2.floating_prometheus.address
}