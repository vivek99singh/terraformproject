output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Name of the resource group"
}

output "resource_group_location" {
  value       = azurerm_resource_group.main.location
  description = "Location of the resource group"
}

output "vm_public_ip" {
  value       = module.network.public_ip_address
  description = "Public IP address of the VM"
}

output "vm_id" {
  value       = module.vm.vm_id
  description = "ID of the virtual machine"
}

output "vm_name" {
  value       = module.vm.vm_name
  description = "Name of the virtual machine"
}