output "storage_account_id" {
  value = module.storage_account.storage_account_id
}

output "resource_group_id" {
  value = azurerm_resource_group.storage_rg.id
}