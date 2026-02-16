output "sql_database_id" {
  value       = module.azure_sql_database.sql_database_id
  description = "The ID of the Azure SQL Database"
}

output "sql_server_id" {
  value       = module.azure_sql_database.sql_server_id
  description = "The ID of the Azure SQL Server hosting the database"
}