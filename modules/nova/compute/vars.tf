variable "hostname" {
  default = "hostname"
  type = string
}

# openstack flavor show PRC20.2-2048 -c id -f value
variable "flavor_id" {
  default = "9023"
  type = string
}

variable "availability_zone" {
  default     = "ru-9a"
  type        = string
  description = "The availability zone to use"
}

variable "image_id" {
  default     = "image_id"
  type        = string
  description = "The ID of the image to use"
}

variable "volume_size" {
  default     = "40"
  type        = string
  description = "The volume size to use"
}

variable "key_pair" {
  default     = "key_pair"
  type        = string
  sensitive   = true
}

variable "first_port_id" {
  default = "0"
  type = string
}

variable "second_port_id" {
  default = "0"
  type = string
}

variable "user_data" {
  default = "init_vm.sh"
  type = string
}