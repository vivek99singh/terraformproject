output "subnet_id" {
  value       = azurerm_subnet.main[0].id
  description = "ID of the first subnet"
}

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "ID of the public IP"
}

output "nsg_id" {
  value       = azurerm_network_security_group.main.id
  description = "ID of the network security group"
}