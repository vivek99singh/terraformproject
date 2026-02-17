output "vm_id" {
  value       = azurerm_windows_virtual_machine.main.id
  description = "ID of the virtual machine"
}

output "vm_name" {
  value       = azurerm_windows_virtual_machine.main.name
  description = "Name of the virtual machine"
}

output "nic_id" {
  value       = azurerm_network_interface.main.id
  description = "ID of the network interface"
}

output "admin_password" {
  value       = random_password.admin.result
  description = "Admin password for the virtual machine"
  sensitive   = true
}