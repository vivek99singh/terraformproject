output "database_id" {
  value       = azurerm_mssql_database.main.id
  description = "ID of the Azure SQL Database"
}

output "server_name" {
  value       = azurerm_mssql_server.main.name
  description = "Name of the Azure SQL Server"
}

output "firewall_rule_id" {
  value       = azurerm_mssql_firewall_rule.allow_ip.id
  description = "ID of the Azure SQL Firewall Rule"
}