variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy the resources"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR for the virtual network"
  type        = string
}

variable "subnet_cidrs" {
  description = "List of CIDRs for the subnets"
  type        = list(string)
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
  default     = "adminuser"
}