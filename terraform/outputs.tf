output "mssql_server_name" {
  value       = azurerm_mssql_server.main.name
  description = "Name of the MSSQL Server"
}

output "mssql_database_name" {
  value       = azurerm_mssql_database.main.name
  description = "Name of the MSSQL Database"
}

output "mssql_server_fqdn" {
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  description = "Fully Qualified Domain Name of the MSSQL Server"
}

output "sql_admin_password" {
  value       = random_password.sql_admin_password.result
  description = "SQL Server Administrator Password"
  sensitive   = true
}