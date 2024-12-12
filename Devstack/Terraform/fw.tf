resource "openstack_fw_rule_v2" "rule_1" {
  name             = "Input_rule_1"
  description      = "Allow only ingoing selectel subnet"
  action           = "allow"
  protocol         = "any"
  source_ip_address = "188.93.16.0/22"
  enabled          = "true"
}

resource "openstack_fw_rule_v2" "rule_2" {
  name             = "Output_rule_1"
  description      = "Allow all outgoing traffic"
  action           = "allow"
  protocol         = "any"
  enabled          = "true"
}