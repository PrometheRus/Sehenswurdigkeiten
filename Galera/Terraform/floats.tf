resource "openstack_networking_floatingip_v2" "floatingip_lb" {
  pool    = "external-network"
  port_id = openstack_lb_loadbalancer_v2.load_balancer_1.vip_port_id
}

# Assign a PUBLIC IP for the 'Bastion' instance
resource "openstack_networking_floatingip_v2" "floating_bastion" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_bastion" {
  port_id     = openstack_networking_port_v2.port_bastion.id
  floating_ip = openstack_networking_floatingip_v2.floating_bastion.address
}