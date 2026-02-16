variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (Dev, Stage, Prod)."
  type        = string
  default     = "Dev"
}

variable "vnet_cidr" {
  description = "CIDR for the virtual network."
  type        = string
}

variable "subnet_cidrs" {
  description = "List of CIDRs for the subnets."
  type        = list(string)
}

variable "vm_size" {
  description = "Size of the VM."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "adminuser"
}