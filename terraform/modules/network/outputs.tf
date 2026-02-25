output "subnet_id" {
  description = "ID of the first subnet"
  value       = try(values(azurerm_subnet.main)[0].id, azurerm_subnet.main[0].id)
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = try([for s in azurerm_subnet.main : s.id], azurerm_subnet.main[*].id)
}

output "nsg_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the network security group"
}

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "ID of the public IP"
}

output "public_ip_address" {
  value       = azurerm_public_ip.main.ip_address
  description = "Public IP address"
}

output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "ID of the virtual network"
}