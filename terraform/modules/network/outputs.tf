output "subnet_id" {
  value       = values(azurerm_subnet.main)[0].id
  description = "ID of the first subnet"
}

output "subnet_ids" {
  value       = [for s in azurerm_subnet.main : s.id]
  description = "IDs of all subnets"
}

output "nsg_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the Network Security Group"
}

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "ID of the Public IP"
}

output "public_ip_address" {
  value       = azurerm_public_ip.main.ip_address
  description = "Public IP address"
}

output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "ID of the Virtual Network"
}