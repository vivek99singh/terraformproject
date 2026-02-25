output "primary_blob_endpoint" {
  value       = azurerm_storage_account.main.primary_blob_endpoint
  description = "The primary blob endpoint of the storage account"
}

output "primary_access_key" {
  value       = azurerm_storage_account.main.primary_access_key
  description = "The primary access key of the storage account"
  sensitive   = true
}