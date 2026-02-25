output "database_id" {
  value       = azurerm_mssql_database.main.id
  description = "ID of the SQL Database"
}

output "server_name" {
  value       = azurerm_mssql_server.main.name
  description = "Name of the SQL Server"
}