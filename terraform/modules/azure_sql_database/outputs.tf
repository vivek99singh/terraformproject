output "sql_server_id" {
  value       = azurerm_mssql_server.main.id
  description = "ID of the Azure SQL Server"
}

output "sql_database_id" {
  value       = azurerm_mssql_database.main.id
  description = "ID of the Azure SQL Database"
}

output "firewall_rule_id" {
  value       = azurerm_mssql_firewall_rule.allow_ip.id
  description = "ID of the Azure SQL Firewall Rule"
}