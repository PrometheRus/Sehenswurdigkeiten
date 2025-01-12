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

# openstack image show 'Ubuntu 24.04 LTS 64-bit' -c id -f value
variable "image_id" {
  default     = "ca1d5915-62a8-40e9-b104-0801b0791ec6" # Ubuntu 24.04
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

variable "enable_resource" {
  type    = bool
  default = false
}