output "controller" {
  value = module.float_controller.floatingip_address
}

output "cmp1" {
  value = module.float_cmp1.floatingip_address
}

output "cmp2" {
  value = module.float_cmp2.floatingip_address
}