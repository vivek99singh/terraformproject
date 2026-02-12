variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
  default     = "eastus"
}

variable "resource_name" {
  description = "Name of the resource"
  type        = string
  default     = "resource"
}

variable "vnet_cidr" {
  description = "CIDR notation for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}