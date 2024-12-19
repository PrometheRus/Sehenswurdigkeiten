# Assign a PUBLIC IP for the Grafana Instance
resource "openstack_networking_floatingip_v2" "floatingip_grafana" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_1" {
  port_id     = openstack_networking_port_v2.port_grafana.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_grafana.address
}

# Assign a PUBLIC IP for the Docker Instance
resource "openstack_networking_floatingip_v2" "floatingip_docker" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_2" {
  port_id     = openstack_networking_port_v2.port_docker.id
  floating_ip = openstack_networking_floatingip_v2.floatingip_docker.address
}