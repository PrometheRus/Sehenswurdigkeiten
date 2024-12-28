variable "flavor_id" {
  default     = "9023" # PRC20.2-2048
  type        = string
  description = "The ID of the flavor to use"
}

variable "image_id" {
  default     = "39d6e457-e0d7-4e5d-ad64-261f72c86bdc" # Alma9
  type        = string
  description = "The ID of the image to use"
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

variable "auth_region" {
  default     = "ru-9"
  type        = string
  description = "The availability auth zone to use == availability_zone"
}