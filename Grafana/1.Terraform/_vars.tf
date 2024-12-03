variable "selectel-domain" {
  default     = ""
  type        = string
  description = "The id of the user account"
}

### The project is already created. Using its data
variable "selectel-project-name" {
  default     = "grafana"
  type        = string
  description = "The name of the project"
}

variable "selectel-project-id" {
  default     = "24be296522cf432ba785fbe00eb1e607"
  type        = string
  description = "The id of the project"
}


### The service account is already created. Using its data
variable "service-account-main-name" {
  default     = "service-account-grafana"
  type        = string
  description = "The name of the service account"
}

variable "service-account-main-password" {
  default     = ""
  type        = string
  description = "The password of the service account"
}

variable "service-account-main-id" {
  default     = ""
  type        = string
  description = "The ID of the service account"
}