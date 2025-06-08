variable "region" {
  default     = "ru-7"
}

variable "domain" {
  default     = "<domain-id>"
  description = "The id of the user account"
  sensitive   = true
}

variable "service-account-name" {
  default     = "<name>"
  description = "The name of the service account"
  sensitive   = true
}

variable "service-account-password" {
  default     = "<password>"
  description = "The password of the service account"
  sensitive   = true
}

variable "service-account-id" {
  default     = "<account-id>"
  description = "The ID of the service account"
  sensitive   = true
}

variable "project_name" {
  default = "ceph"
}