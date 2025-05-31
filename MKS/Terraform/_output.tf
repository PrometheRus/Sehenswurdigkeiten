output "latest_version" {
  value = data.selectel_mks_kube_versions_v1.versions.latest_version
}

output "default_version" {
  value = data.selectel_mks_kube_versions_v1.versions.default_version
}

output "versions" {
  value = data.selectel_mks_kube_versions_v1.versions.versions
}