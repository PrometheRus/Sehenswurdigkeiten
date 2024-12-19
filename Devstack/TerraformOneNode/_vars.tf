variable "domain" {
  default     = "{{ REPLACE ME}}"
  type        = string
  description = "The id of the user account"
}

variable "project-id" {
  default     = "{{ REPLACE ME}}"
  type        = string
  description = "The id of the project"
}

### The service account is already created. Using its data
variable "service-account-name" {
  default     = "{{ REPLACE ME}}"
  type        = string
  description = "The name of the service account"
}

variable "service-account-password" {
  default     = "{{ REPLACE ME}}"
  type        = string
  description = "The password of the service account"
}

variable "service-account-id" {
  default     = "{{ REPLACE ME}}"
  type        = string
  description = "The ID of the service account"
}

variable "flavor_id" {
  default     = "1014" # SL1.2-8192
  type        = string
  description = "The ID of the flavor to use"
}

variable "image_id" {
  default     = "3c4101af-4e1b-461c-ac51-2d5905ad7408" # Ubuntu 24.04
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
  default     = "20"
  type        = string
  description = "The volume size to use"
}

variable "auth_region" {
  default     = "ru-9"
  type        = string
  description = "The availability auth zone to use == availability_zone"
}