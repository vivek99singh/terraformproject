output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "storage_account_primary_blob_endpoint" {
  value = azurerm_storage_account.bootdiag.primary_blob_endpoint
}

output "network_subnet_ids" {
  value = module.network.subnet_ids
}

output "vm_id" {
  value = module.vm.vm_id
}

output "vm_public_ip_address" {
  value = module.network.public_ip_address
}