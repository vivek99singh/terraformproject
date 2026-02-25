output "vm_id" {
  value       = azurerm_windows_virtual_machine.main.id
  description = "The ID of the virtual machine"
}

output "vm_name" {
  value       = azurerm_windows_virtual_machine.main.name
  description = "The name of the virtual machine"
}

output "nic_id" {
  value       = azurerm_network_interface.main.id
  description = "The ID of the network interface"
}

output "admin_password" {
  value       = random_password.admin.result
  description = "The admin password for the VM"
  sensitive   = true
}