variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
  }
}

variable "vnet_cidr" {
  type = string
}

variable "subnet_cidrs" {
  type = list(string)
}

variable "vm_size" {
  type = string
  default = "Standard_D2s_v5"
}

variable "admin_username" {
  type = string
  default = "adminuser"
}