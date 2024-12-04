resource "openstack_lb_loadbalancer_v2" "load_balancer_1" {
  name          = "load-balancer"
  vip_subnet_id = openstack_networking_subnet_v2.subnet_1.id
  flavor_id     = "ac18763b-1fc5-457d-9fa7-b0d339ffb336"
}

# Create a listener
resource "openstack_lb_listener_v2" "listener_1" {
  name            = "listener"
  protocol        = "TCP"
  protocol_port   = "3306"
  loadbalancer_id = openstack_lb_loadbalancer_v2.load_balancer_1.id
}

# Create a group
resource "openstack_lb_pool_v2" "pool_1" {
  name        = "pool"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_1.id
}

# Add members
resource "openstack_lb_member_v2" "member_1" {
  name          = "member"
  subnet_id     = openstack_networking_subnet_v2.subnet_1.id
  pool_id       = openstack_lb_pool_v2.pool_1.id
  address       = openstack_compute_instance_v2.nginx1.access_ip_v4
  protocol_port = "3306"
}

resource "openstack_lb_member_v2" "member_2" {
  name          = "member"
  subnet_id     = openstack_networking_subnet_v2.subnet_1.id
  pool_id       = openstack_lb_pool_v2.pool_1.id
  address       = openstack_compute_instance_v2.nginx2.access_ip_v4
  protocol_port = "3306"
}

# Add availability check
resource "openstack_lb_monitor_v2" "monitor_1" {
  name        = "monitor"
  pool_id     = openstack_lb_pool_v2.pool_1.id
  type        = "TCP"
  delay       = "10"
  timeout     = "4"
  max_retries = "5"
}