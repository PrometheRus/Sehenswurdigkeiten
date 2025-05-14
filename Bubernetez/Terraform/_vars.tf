# openstack flavor show PRC20.2-2048 -c id -f value
variable "flavor_id" {
  default     = "9023"
  type        = string
  description = "The ID of the flavor to use"
}

# ПОДСТАВЬ СВОЕ ЗНАЧЕНИЕ ПРИ НЕОБХОДИМОСТИ
# RU-2 dc1a5b5a-acda-4cda-b92d-427579ce6169
# RU-3 418c8a04-1a7e-4402-9e10-4ae280067be8
# RU-7 b417e345-3ab1-48c4-b8af-8cb2834b2f4d
# RU-9 2c380e7a-c865-465f-801e-7d82913770d1

# openstack image show 'Alma Linux 9 64-bit' -c id -f value
variable "image_id" {
  default     = "8940861e-68cc-4a63-82c5-b0fa6ce79087" # Alma9
  type        = string
  description = "The ID of the image to use"
}

variable "availability_zone" {
  default     = "ru-9a"
  type        = string
  description = "The availability zone to use"
}

variable "auth_region" {
  default     = "ru-9"
  type        = string
  description = "The availability auth zone to use == availability_zone"
}

variable "volume_size" {
  default     = "20"
  type        = string
  description = "The volume size to use"
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