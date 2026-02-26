output "subnet_id" {
  description = "ID of the first subnet"
  value       = try(values(azurerm_subnet.main)[0].id, azurerm_subnet.main[0].id)
}

output "nsg_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the network security group"
}

output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "ID of the virtual network"
}