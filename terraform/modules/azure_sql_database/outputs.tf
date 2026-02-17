output "mssql_server_id" {
  value       = azurerm_mssql_server.main.id
  description = "The ID of the MSSQL Server"
}

output "mssql_database_id" {
  value       = azurerm_mssql_database.main.id
  description = "The ID of the MSSQL Database"
}