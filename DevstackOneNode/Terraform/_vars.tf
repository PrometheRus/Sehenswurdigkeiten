variable "flavor_id" {
  default     = "1014" # SL1.2-8192
  type        = string
  description = "The ID of the flavor to use"
}

variable "image_id" {
  default     = "2c1605fc-940b-4b22-bfa7-65f2c22aa662" # Ubuntu 24.04
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