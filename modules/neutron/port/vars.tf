variable "instance_name" {
  default = "demo"
  type = string
}

variable "network_id" {
  default = "0"
  type = string
}

variable "first_subnet_id" {
  default = "0"
  type = string
}

variable "second_subnet_id" {
  default = "0"
  type = string
}

variable "first_subnet_ip" {
  default = "192.168.11.10"
  type = string
}

variable "second_subnet_ip" {
  default = "192.168.11.20"
  type = string
}