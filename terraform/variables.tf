variable "location" {
  description = "The Azure region to deploy the resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "resource-group"
}

variable "vnet_cidr" {
  description = "CIDR notation for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

provider "azurerm" {
  features {}
}