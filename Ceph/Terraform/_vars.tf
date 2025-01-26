# openstack flavor show PRC10.2-2048 -c id -f value
variable "flavor_prc" {
  default     = "9013"
  type        = string
  description = "The ID of the flavor to use"
}

# openstack image show "Alma Linux 9 64-bit" -c id -f value
variable "image_id" {
  default     = "57b23612-6b83-4e6f-b7b3-0c5df13fedd9" # Alma9
  type        = string
  description = "The ID of the image to use"
}

variable "auth_region" {
  default     = "ru-7"
  type        = string
  description = "The availability auth zone to use == availability_zone"
}

variable "availability_zone" {
  default     = "ru-7a"
  type        = string
  description = "The availability zone to use"
}

variable "volume_size" {
  default     = "20"
  type        = string
  description = "The volume size to use"
}

variable "ceph_volume_size" {
  default     = "30"
  type        = string
  description = "The volume size to use"
}