output "sql_server_id" {
  value       = azurerm_mssql_server.main.id
  description = "ID of the SQL Server"
}

output "sql_database_id" {
  value       = azurerm_mssql_database.main.id
  description = "ID of the SQL Database"
}