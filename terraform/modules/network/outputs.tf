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