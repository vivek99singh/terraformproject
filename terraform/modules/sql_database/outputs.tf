output "database_id" {
  value       = azurerm_mssql_database.main.id
  description = "ID of the Azure SQL Database"
}