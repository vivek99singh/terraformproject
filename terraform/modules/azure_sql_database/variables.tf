variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for the Azure SQL Database"
}

variable "location" {
  type        = string
  description = "Azure region where the SQL Database will be deployed"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the resources"
}