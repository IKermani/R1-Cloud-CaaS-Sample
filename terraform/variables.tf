# Define variables
variable "user_name" {
  description = "username"
  default     = "admin"
}

variable "tenant_name" {
  description = "tenant name"
  default     = "admin"
}

variable "password" {
  description = "password"
  default     = "supersecretpassword"
}

variable "auth_url" {
  description = "OpenStack authentication URL"
  default     = "http://myauthurl:5000/v2.0"
}

variable "region" {
  description = "region name"
  default     = "RegionOne"
}

variable "image_name" {
  description = "Name of the image to use for the VMs"
  default     = "your_image_name"
}

variable "flavor_name" {
  description = "Name of the flavor (VM size) to use for the VMs"
  default     = "your_flavor_name"
}

variable "network_name" {
  description = "Name of the network to use for the VMs"
  default     = "your_network_name"
}