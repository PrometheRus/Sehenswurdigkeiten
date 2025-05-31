# openstack flavor show PRC10.2-2048 -c id -f value
variable "flavor_prc" {
  default     = "9013"
  type        = string
  description = "The ID of the flavor to use"
}

variable "availability_zone" {
  default     = "ru-9a"
  type        = string
  description = "The availability zone to use"
}

variable "auth_region" {
  default     = "ru-9"
  type        = string
  description = "The region to use"
}

variable "volume_size" {
  default     = "15"
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