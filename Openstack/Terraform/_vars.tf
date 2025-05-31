# openstack flavor show CPU1.4-8192 -c id -f value
variable "flavor_id" {
  default     = "2011"
  type        = string
  description = "The ID of the flavor to use"
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

variable "enable_resource" {
  default = false
  type = bool
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