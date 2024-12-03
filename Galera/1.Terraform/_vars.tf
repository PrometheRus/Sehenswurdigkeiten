variable "selectel-domain" {
  default     = "390181"
  type        = string
  description = "The id of the user account"
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

variable "flavor_id" {
  default     = "1012"
  type        = string
  description = "The ID of the flavor to use"
}

variable "image_id" {
  default     = "b671a80e-9bf0-4861-9833-bd711bd8a02f"    # Ubuntu 24.04
  type        = string
  description = "The ID of the image to use"
}