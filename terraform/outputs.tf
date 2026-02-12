output "resource_group_name" {
  value = azurerm_resource_group.storage_rg.name
}

output "vnet_name" {
  value = azurerm_virtual_network.storage_vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.storage_subnet.name
}

output "nsg_name" {
  value = azurerm_network_security_group.storage_nsg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.storage_public_ip.ip_address
}

output "network_interface_id" {
  value = azurerm_network_interface.storage_nic.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}