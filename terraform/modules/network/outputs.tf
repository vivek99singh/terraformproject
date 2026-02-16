output "subnet_id" {
  value = values(azurerm_subnet.main)[0].id
}

output "nsg_id" {
  value = azurerm_network_security_group.main.id
}

output "public_ip_id" {
  value = azurerm_public_ip.main.id
}

output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}