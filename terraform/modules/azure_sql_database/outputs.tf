output "sql_database_id" {
  value       = azurerm_mssql_database.sql_database.id
  description = "The ID of the Azure SQL Database"
}

output "sql_server_id" {
  value       = azurerm_mssql_server.sql_server.id
  description = "The ID of the Azure SQL Server"
}