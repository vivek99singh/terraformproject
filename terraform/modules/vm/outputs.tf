output "vm_id" {
  value = azurerm_windows_virtual_machine.main.id
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.main.name
}

output "nic_id" {
  value = azurerm_network_interface.main.id
}

output "admin_password" {
  value = random_password.admin.result
  sensitive = true
}