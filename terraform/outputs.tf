output "sql_database_id" {
  value       = module.azure_sql.database_id
  description = "ID of the SQL Database"
}

output "sql_server_name" {
  value       = module.azure_sql.server_name
  description = "Name of the SQL Server"
}