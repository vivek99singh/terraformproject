variable "resource_group_name" {
  description = "The name of the resource group."
}

variable "location" {
  description = "The Azure region to deploy the VM."
}

variable "network_interface_id" {
  description = "The ID of the network interface to attach to the VM."
}