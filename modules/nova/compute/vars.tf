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

# openstack image show "Alma Linux 9 64-bit" -c id -f value
variable "image_id" {
  default     = "de41300f-f49d-4d95-a988-3fd3db1e9e4e" # Alma9
  type        = string
  description = "The ID of the image to use"
}

variable "volume_size" {
  default     = "20"
  type        = string
  description = "The volume size to use"
}

variable "key_pair" {
  default     = "<name>"
  description = "Type the command and get the name: 'openstack keypair list'"
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