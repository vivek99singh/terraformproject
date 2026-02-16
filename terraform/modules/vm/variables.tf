variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_ip_id" {
  type        = string
  default     = null
}

variable "nsg_id" {
  type        = string
  default     = null
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  default     = null
}