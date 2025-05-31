data "selectel_mks_kube_versions_v1" "versions" {
  project_id = selectel_vpc_project_v2.new_project.id
  region     = var.auth_region
}

data "selectel_mks_kubeconfig_v1" "kubeconfig" {
  cluster_id = selectel_mks_cluster_v1.basic_cluster.id
  project_id = selectel_mks_cluster_v1.basic_cluster.project_id
  region     = selectel_mks_cluster_v1.basic_cluster.region
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

resource "selectel_mks_nodegroup_v1" "nodegroup_1" {
  cluster_id        = selectel_mks_cluster_v1.basic_cluster.id
  project_id        = selectel_mks_cluster_v1.basic_cluster.project_id
  region            = selectel_mks_cluster_v1.basic_cluster.region
  availability_zone = var.availability_zone
  nodes_count       = 2
  cpus              = 2
  ram_mb            = 4096
  volume_gb         = var.volume_size
  volume_type       = "basic.${var.availability_zone}"

  install_nvidia_device_plugin = false
  preemptible                  = false

  labels            = {
    "label-key0": "label-value0",
    "label-key1": "label-value1",
    "label-key2": "label-value2",
  }
  taints {
    key    = "test-key-0"
    value  = "test-value-0"
    effect = "NoSchedule"
  }
  taints {
    key    = "test-key-1"
    value  = "test-value-1"
    effect = "NoExecute"
  }
  taints {
    key    = "test-key-2"
    value  = "test-value-2"
    effect = "PreferNoSchedule"
  }
}