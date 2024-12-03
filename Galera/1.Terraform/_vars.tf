variable "selectel-domain" {
  default     = "{{ REPLACE ME }}>"
  type        = string
  description = "The id of the user's domain"
}

variable "selectel-project-id" {
  default     = "{{ REPLACE ME }}"
  type        = string
  description = "The id of the project"
}


### The service account is already created. Using its data
variable "service-account-main-name" {
  default     = "{{ REPLACE ME }}"
  type        = string
  description = "The name of the service account"
}

variable "service-account-main-password" {
  default     = "{{ REPLACE ME }}"
  type        = string
  description = "The password of the service account"
}

variable "service-account-main-id" {
  default     = "{{ REPLACE ME }}"
  type        = string
  description = "The ID of the service account"
}

variable "flavor_id" {
  default     = "1012"                                    # SL1.1-2048
  type        = string
  description = "The ID of the flavor to use"
}

variable "image_id" {
  default     = "b671a80e-9bf0-4861-9833-bd711bd8a02f"    # Ubuntu 24.04
  type        = string
  description = "The ID of the image to use"
}