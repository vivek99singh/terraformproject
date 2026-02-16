output "sql_database_id" {
  value       = azurerm_mssql_database.main.id
  description = "The ID of the Azure SQL Database."
}

output "sql_database_name" {
  value       = azurerm_mssql_database.main.name
  description = "The name of the Azure SQL Database."
}