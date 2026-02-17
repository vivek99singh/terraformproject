output "sql_database_id" {
  value       = module.azure_sql_database.database_id
  description = "ID of the Azure SQL Database"
}

output "sql_server_name" {
  value       = module.azure_sql_database.server_name
  description = "Name of the Azure SQL Server"
}

output "sql_firewall_rule_id" {
  value       = module.azure_sql_database.firewall_rule_id
  description = "ID of the Azure SQL Firewall Rule"
}