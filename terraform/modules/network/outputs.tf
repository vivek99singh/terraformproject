output "subnet_id" {
  description = "ID of the first subnet"
  value       = azurerm_subnet.main[0].id
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = azurerm_public_ip.main.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.main.ip_address
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}