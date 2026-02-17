output "subnet_id" {
  description = "ID of the first subnet"
  value       = values(azurerm_subnet.main)[0].id
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = [for s in azurerm_subnet.main : s.id]
}

output "nsg_id" {
  value = azurerm_network_security_group.main.id
}

output "public_ip_id" {
  value = azurerm_public_ip.main.id
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}