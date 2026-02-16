variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy the resources"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
  }
}

variable "vnet_cidr" {
  type        = string
  description = "The CIDR block for the virtual network"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks for the subnets"
}

variable "vm_size" {
  type        = string
  description = "The size of the virtual machine"
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type        = string
  description = "The admin username for the virtual machine"
  default     = "adminuser"
}