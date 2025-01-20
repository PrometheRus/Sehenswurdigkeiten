# openstack flavor show PRC10.2-2048 -c id -f value
variable "flavor_prc" {
  default     = "9013"
  type        = string
  description = "The ID of the flavor to use"
}

# openstack flavor show PRC50.4-8192 -c id -f value
variable "flavor_ctrl" {
  default     = "9055"
  type        = string
  description = "The ID of the flavor to use"
}

# openstack image show "Alma Linux 9 64-bit" -c id -f value
variable "image_id" {
  default     = "de41300f-f49d-4d95-a988-3fd3db1e9e4e" # Alma9
  type        = string
  description = "The ID of the image to use"
}

variable "auth_region" {
  default     = "ru-9"
  type        = string
  description = "The availability auth zone to use == availability_zone"
}

variable "availability_zone" {
  default     = "ru-9a"
  type        = string
  description = "The availability zone to use"
}

variable "volume_size" {
  default     = "20"
  type        = string
  description = "The volume size to use"
}