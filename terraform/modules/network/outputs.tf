output "subnet_ids" {
  value = [for s in azurerm_subnet.main : s.id]
}

output "nsg_id" {
  value = azurerm_network_security_group.main.id
}