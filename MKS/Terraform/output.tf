output "latest_version" {
  value = data.selectel_mks_kube_versions_v1.versions.latest_version
}

output "default_version" {
  value = data.selectel_mks_kube_versions_v1.versions.default_version
}

output "versions" {
  value = data.selectel_mks_kube_versions_v1.versions.versions
}

output "kubeconfig" {
  value = data.selectel_mks_kubeconfig_v1.kubeconfig.raw_config
  sensitive = true
}