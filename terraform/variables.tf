variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure region to deploy the resources."
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the virtual network."
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets."
}

variable "vm_size" {
  type        = string
  description = "The size of the VM."
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
  default     = "adminuser"
}

variable "tags" {
  type    = map(string)
  default = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
  }
}