variable "hostname" {
  default = "default_hostname"
}

variable "project" {
  default = "default_project"
}

variable "first_subnet" {
  default = "192.168.11.0/24"
}

variable "second_subnet" {
  default ="192.168.12.0/24"
}

variable "first_subnet_ip" {
  default = "192.168.11.10"
}

variable "second_subnet_ip" {
  default = "192.168.11.20"
}

variable "external-network" {
  default = ""
}