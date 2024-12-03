variable "selectel-domain" {
  default     = "390181"
  type        = string
  description = "The id of the user account"
}

### The project is already created. Using its data
variable "selectel-project-name" {
  default     = "Default"
  type        = string
  description = "The name of the project"
}

variable "selectel-project-id" {
  default     = "bcbf57bfdcdb49ce9aa71218bef54283"
  type        = string
  description = "The id of the project"
}


### The service account is already created. Using its data
variable "service-account-main-name" {
  default     = "service-account-main"
  type        = string
  description = "The name of the service account"
}

variable "service-account-main-password" {
  default     = "{-n4-Ye5"
  type        = string
  description = "The password of the service account"
}

variable "service-account-main-id" {
  default     = "c668b8ab398c4685aa5b621b4c5a3693"
  type        = string
  description = "The ID of the service account"
}