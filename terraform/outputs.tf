output "sql_server_name" {
  value       = azurerm_mssql_server.main.name
  description = "Name of the SQL server"
}

output "sql_database_name" {
  value       = azurerm_mssql_database.main.name
  description = "Name of the SQL database"
}

output "sql_admin_login" {
  value       = azurerm_mssql_server.main.administrator_login
  description = "Administrator login for the SQL server"
}

output "sql_admin_password" {
  value       = random_password.sql_admin_password.result
  description = "Administrator password for the SQL server"
  sensitive   = true
}