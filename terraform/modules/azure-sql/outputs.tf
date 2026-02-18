output "sql_server_id" {
  value       = azurerm_mssql_server.main.id
  description = "ID of the Azure SQL Server"
}

output "sql_database_id" {
  value       = azurerm_mssql_database.main.id
  description = "ID of the Azure SQL Database"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  description = "Fully Qualified Domain Name of the Azure SQL Server"
}