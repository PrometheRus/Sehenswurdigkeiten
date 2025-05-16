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

variable "s3key" {
  default = ""
  type = string
  sensitive = true
}