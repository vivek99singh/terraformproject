output "sql_server_id" {
  value       = module.azure_sql.sql_server_id
  description = "ID of the SQL Server"
}

output "sql_database_id" {
  value       = module.azure_sql.sql_database_id
  description = "ID of the SQL Database"
}