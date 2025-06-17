# ПОДСТАВЬ СВОЕ ЗНАЧЕНИЕ ПРИ НЕОБХОДИМОСТИ
variable "volume_size" {
  default     = "20"
  type        = string
  description = "The volume size to use"
}

variable "region" {
  default     = "ru-9"
  type        = string
  description = "The availability auth zone to use == availability_zone"
}


variable "domain" {
  default     = "<domain-id>"
  type        = string
  description = "The id of the user account"
  sensitive   = true
}

variable "project-id" {
  default     = "<project-id>"
  type        = string
  description = "The id of the project"
  sensitive   = true
}

variable "project-name" {
  default     = "mks"
  type        = string
  description = "The name of the project"
  sensitive   = true
}

variable "service-account-name" {
  default     = "<name>"
  type        = string
  description = "The name of the service account"
  sensitive   = true
}

variable "service-account-password" {
  default     = "<password>"
  type        = string
  description = "The password of the service account"
  sensitive   = true
}

variable "service-account-id" {
  default     = "<account-id>"
  type        = string
  description = "The ID of the service account"
  sensitive   = true
}

variable "service-ssh-key-name" {
  default     = "<name>"
  description = "Type the command and get the name: 'openstack keypair list'"
  type        = string
  sensitive   = true
}