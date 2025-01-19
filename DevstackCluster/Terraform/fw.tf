resource "openstack_fw_rule_v2" "rule_selectel" {
  name                   = "allow-selectel"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "188.93.16.0/22"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_home" {
  name                   = "allow-home"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "185.97.200.0/22"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_egress" {
  name                   = "allow-engress"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "0.0.0.0/0"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_policy_v2" "policy_1" {
  name    = "ingress-policy"
  audited = true
  rules = [
    openstack_fw_rule_v2.rule_selectel.id, openstack_fw_rule_v2.rule_home.id
  ]
}

resource "openstack_fw_policy_v2" "policy_2" {
  name    = "egress-policy"
  audited = true
  rules = [
    openstack_fw_rule_v2.rule_egress.id,
  ]
}

resource "openstack_fw_group_v2" "group_1" {
  name                       = "firewall_group"
  admin_state_up             = true
  ingress_firewall_policy_id = openstack_fw_policy_v2.policy_1.id
  egress_firewall_policy_id  = openstack_fw_policy_v2.policy_2.id
  ports = [
    openstack_networking_router_interface_v2.router_interface_1.port_id
  ]
}