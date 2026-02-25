variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "rg-sql-production"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "Prod"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
  }
}