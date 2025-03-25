# ПОДСТАВЬ СВОЕ ЗНАЧЕНИЕ ПРИ НЕОБХОДИМОСТИ
# openstack flavor show SL1.4-16384 -c id -f value
variable "flavor_id" {
  default     = "9023" # PRC20.2-2048
  type        = string
  description = "The ID of the flavor to use"
}

# ПОДСТАВЬ СВОЕ ЗНАЧЕНИЕ ПРИ НЕОБХОДИМОСТИ
# openstack image show 'Alma Linux 9 64-bit' -c id -f value
variable "image_id" {
  default     = "2c380e7a-c865-465f-801e-7d82913770d1" # Alma9
  type        = string
  description = "The ID of the image to use"
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

variable "auth_region" {
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
  default     = "<project-name>"
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

variable "temp-service-account-name" {
  default     = "<name>"
  type        = string
  description = "The name of the service account for the new project"
  sensitive   = true
}

variable "temp-service-account-password" {
  default     = "<password>"
  type        = string
  description = "The password of the service account for the new project"
  sensitive   = true
}