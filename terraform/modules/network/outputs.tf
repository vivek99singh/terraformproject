output "virtual_network_name" {
  value = azurerm_virtual_network.main.name
}

output "subnet_name" {
  value = azurerm_subnet.main.name
}

output "network_interface_id" {
  value = azurerm_network_interface.main.id
}