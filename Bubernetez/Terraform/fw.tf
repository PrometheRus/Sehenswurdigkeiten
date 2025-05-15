resource "openstack_fw_rule_v2" "rule_1" {
  name                   = "allow-private-second"
  action                 = "allow"
  protocol               = "tcp"
  source_ip_address      = "192.168.10.0/24"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_2" {
  name                   = "allow-selectel"
  action                 = "allow"
  protocol               = "tcp"
  source_ip_address      = "188.93.16.0/22"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_3" {
  name                   = "allow-engress"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "0.0.0.0/0"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_ISP" {
  name                   = "allow-ISP"
  action                 = "allow"
  protocol               = "tcp"
  source_ip_address      = "185.97.200.0/22"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_policy_v2" "firewall_ingress_1" {
  name    = "ingress-firewall-policy"
  audited = true
  rules = [
    openstack_fw_rule_v2.rule_1.id, openstack_fw_rule_v2.rule_2.id, openstack_fw_rule_v2.rule_ISP.id
  ]
}

resource "openstack_fw_policy_v2" "firewall_egress_1" {
  name    = "egress-firewall-policy"
  audited = true
  rules   = [
    openstack_fw_rule_v2.rule_3.id,
  ]
}

resource "openstack_fw_group_v2" "group_1" {
  name                       = "custom-firewall"
  admin_state_up             = true
  ingress_firewall_policy_id = openstack_fw_policy_v2.firewall_ingress_1.id
  egress_firewall_policy_id  = openstack_fw_policy_v2.firewall_egress_1.id
  ports                      = [
    openstack_networking_router_interface_v2.router_interface_1.port_id
  ]
}