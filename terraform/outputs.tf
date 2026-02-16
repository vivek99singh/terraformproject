output "sql_server_id" {
  value       = module.azure_sql_database.sql_server_id
  description = "The ID of the created SQL Server."
}

output "sql_database_id" {
  value       = module.azure_sql_database.sql_database_id
  description = "The ID of the created SQL Database."
}