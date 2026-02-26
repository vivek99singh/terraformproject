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

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "ID of the public IP"
}

output "public_ip_address" {
  value       = azurerm_public_ip.main.ip_address
  description = "Public IP address of the virtual machine"
}

output "admin_password" {
  value       = random_password.admin.result
  description = "Admin password for the virtual machine"
  sensitive   = true
}