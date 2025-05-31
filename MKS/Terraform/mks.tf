data "selectel_mks_kube_versions_v1" "versions" {
  project_id = selectel_vpc_project_v2.new_project.id
  region     = var.auth_region
}

resource "selectel_mks_cluster_v1" "basic_cluster" {
  enable_patch_version_auto_upgrade = false
  kube_version                      = data.selectel_mks_kube_versions_v1.versions.latest_version
  name                              = "cluster-1"
  network_id                        = openstack_networking_network_v2.network_1.id
  project_id                        = selectel_vpc_project_v2.new_project.id
  region                            = var.auth_region
  subnet_id                         = openstack_networking_subnet_v2.subnet_1.id
  zonal                             = true
}