output "sql_server_name" {
  value       = azurerm_mssql_server.main.name
  description = "Name of the SQL Server"
}

output "sql_database_name" {
  value       = azurerm_mssql_database.main.name
  description = "Name of the SQL Database"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  description = "Fully Qualified Domain Name of the SQL Server"
}