output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.cleantest.name
}

output "sql_database_name" {
  description = "The name of the SQL Database"
  value       = azurerm_mssql_database.cleantest.name
}

output "sql_admin_login" {
  description = "The administrator login for the SQL Server"
  value       = azurerm_mssql_server.cleantest.administrator_login
}