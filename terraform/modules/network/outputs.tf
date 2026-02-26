output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "ID of the virtual network"
}

output "subnet_id" {
  value       = azurerm_subnet.main[0].id
  description = "ID of the first subnet"
}

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "ID of the public IP"
}

output "public_ip_address" {
  value       = azurerm_public_ip.main.ip_address
  description = "Public IP address"
}

output "nsg_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the network security group"
}