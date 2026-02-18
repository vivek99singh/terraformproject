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

output "sql_admin_login" {
  value       = azurerm_mssql_server.main.administrator_login
  description = "Administrator login for the SQL Server"
}

output "sql_admin_password" {
  value       = random_password.sql_admin_password.result
  description = "Administrator password for the SQL Server"
  sensitive   = true
}