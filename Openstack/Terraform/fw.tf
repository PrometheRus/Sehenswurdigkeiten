resource "openstack_fw_rule_v2" "rule_1" {
  name                   = "allow-private-second"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "192.168.11.0/25"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_2" {
  name                   = "allow-private-first"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "192.168.12.0/25"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_rule_v2" "rule_3" {
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

resource "openstack_fw_rule_v2" "rule_4" {
  name                   = "allow-engress"
  action                 = "allow"
  protocol               = "any"
  source_ip_address      = "0.0.0.0/0"
  destination_ip_address = "0.0.0.0/0"
}

resource "openstack_fw_policy_v2" "firewall_policy_1" {
  name    = "ingress-firewall-policy"
  audited = true
  rules = [
    openstack_fw_rule_v2.rule_1.id, openstack_fw_rule_v2.rule_2.id, openstack_fw_rule_v2.rule_3.id, openstack_fw_rule_v2.rule_home.id
  ]
}

resource "openstack_fw_policy_v2" "firewall_policy_2" {
  name    = "egress-firewall-policy"
  audited = true
  rules = [
    openstack_fw_rule_v2.rule_4.id,
  ]
}

resource "openstack_fw_group_v2" "group_1" {
  name                       = "custom-firewall"
  admin_state_up             = true
  ingress_firewall_policy_id = openstack_fw_policy_v2.firewall_policy_1.id
  egress_firewall_policy_id  = openstack_fw_policy_v2.firewall_policy_2.id
  ports = [
    openstack_networking_router_interface_v2.router_interface_1.port_id,
    #openstack_networking_router_interface_v2.router_interface_2.port_id,
  ]
}