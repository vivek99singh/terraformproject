variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
  }
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for VNet"
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine"
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "adminuser"
}