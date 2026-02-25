output "primary_blob_endpoint" {
  value       = azurerm_storage_account.main.primary_blob_endpoint
  description = "Primary Blob Endpoint"
}

output "primary_access_key" {
  value       = azurerm_storage_account.main.primary_access_key
  description = "Primary Access Key"
  sensitive   = true
}