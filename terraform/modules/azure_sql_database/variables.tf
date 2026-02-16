variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure region to deploy the resources."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
}