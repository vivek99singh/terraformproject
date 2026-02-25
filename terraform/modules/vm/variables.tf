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

variable "vm_size" {
  type        = string
  description = "Size of the VM"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "public_ip_id" {
  type        = string
  default     = null
  description = "Public IP ID (optional, pass only if public IP is created)"
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

variable "additional_disks" {
  type        = list(object({
    size = number
  }))
  default     = []
  description = "List of additional managed disks to attach to the VM"
}