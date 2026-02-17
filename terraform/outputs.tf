output "sql_server_id" {
  value       = azurerm_mssql_server.main.id
  description = "The ID of the created SQL Server"
}

output "sql_database_id" {
  value       = azurerm_mssql_database.main.id
  description = "The ID of the created SQL Database"
}

output "sql_firewall_rule_id" {
  value       = azurerm_mssql_firewall_rule.allow_specific_ip.id
  description = "The ID of the SQL Firewall Rule allowing access from a specific IP"
}