output "controller" {
  value = module.float_controller.floatingip_address
}

output "cmp1" {
  value = module.float_cmp1.floatingip_address
}

output "cmp2" {
  value = module.float_cmp2.floatingip_address
}

output "grafana" {
  value = module.float_grafana.floatingip_address
}

output "rabbitmq" {
  value = module.float_rabbitmq.floatingip_address
}

output "stat" {
  value = module.float_stat.floatingip_address
}

output "mysql" {
  value = module.float_mysql.floatingip_address
}

output "gw" {
  value = module.float_gw.floatingip_address
}