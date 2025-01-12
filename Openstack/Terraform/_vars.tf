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

variable "image_id" {
  default     = "854fb8ce-1345-44b9-8d0a-c750dae45ab8" # Alma9
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