variable "selectel-domain" {
  default     = "390181"
  type        = string
  description = "The id of the user's domain"
}

variable "selectel-project-id" {
  default     = "f3896bef86594a18bf54e8249631772b"
  type        = string
  description = "The id of the project"
}


### The service account is already created. Using its data
variable "service-account-name" {
  default     = "service-account-galera"
  type        = string
  description = "The name of the service account"
}

variable "service-account-password" {
  default     = "So3]w5oG"
  type        = string
  description = "The password of the service account"
}

variable "service-account-id" {
  default     = "58466c0ce21545e9abb26f8adc859923"
  type        = string
  description = "The ID of the service account"
}

variable "flavor_id" {
  default     = "1012"                                    # SL1.1-2048
  type        = string
  description = "The ID of the flavor to use"
}

variable "image_id" {
  default     = "3c4101af-4e1b-461c-ac51-2d5905ad7408"    # Ubuntu 24.04
  type        = string
  description = "The ID of the image to use"
}

variable "availability_zone" {
  default     = "ru-9a"
  type        = string
  description = "The availability zone to use"
}

variable "volume_type" {
  default     = "basic.ru-9a"
  type        = string
  description = "The volume type to use"
}

variable "volume_size" {
  default     = "15"
  type        = string
  description = "The volume size to use"
}