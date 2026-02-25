output "primary_blob_endpoint" {
  value       = azurerm_storage_account.main.primary_blob_endpoint
  description = "Primary Blob Endpoint of the storage account"
}

output "primary_access_key" {
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
  description = "Primary access key of the storage account"
}