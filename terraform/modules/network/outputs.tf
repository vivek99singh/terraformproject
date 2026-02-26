output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "The ID of the virtual network"
}

output "subnet_id" {
  value       = values(azurerm_subnet.main)[0].id
  description = "The ID of the first subnet"
}

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "The ID of the public IP"
}

output "nsg_id" {
  value       = azurerm_network_security_group.main.id
  description = "The ID of the network security group"
}