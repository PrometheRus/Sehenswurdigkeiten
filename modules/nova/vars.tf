variable "hostname" {
  default = "hostname"
  type = string
}

variable "region" {
  default     = "ru-7"
}

variable "volume_size" {
  default     = "40"
  description = "The volume size to use"
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

variable "project" {
  default = "default_project"
}

variable "distro" {
  default = "Alma Linux 9 64-bit"
}

variable "keypair" {
  default = "default_keypair"
}