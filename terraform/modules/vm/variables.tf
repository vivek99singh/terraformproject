variable "subnet_id" {
  type = string
}

variable "public_ip_id" {
  type = string
}

variable "nsg_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  description = "Storage account URI for boot diagnostics"
}