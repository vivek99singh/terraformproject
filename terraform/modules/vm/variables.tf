variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet for the VM NIC"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "vm_name" {
  type        = string
  default     = "winvm"
  description = "Name of the VM. NIC and PIP names are derived: vm_name-nic, vm_name-pip"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "Size of the VM"
}

variable "admin_username" {
  type        = string
  default     = "adminuser"
  description = "Admin username for the VM"
}

variable "nsg_id" {
  type        = string
  default     = null
  description = "NSG ID (optional, pass only if NSG is created)"
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  default     = null
  description = "Storage account URI for boot diagnostics (optional, pass only if storage account is created)"
}