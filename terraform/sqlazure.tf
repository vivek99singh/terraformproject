# SQL Azure Database Resources
# This file contains Azure SQL Database infrastructure and dependencies

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
}
resource "azurerm_mssql_server" "cleantest" {
  name                         = "cleantest-sql-server"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql_admin_password.result
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}
resource "azurerm_mssql_database" "cleantest" {
  name                = "cleantest-database"
  server_id           = azurerm_mssql_server.cleantest.id
  sku_name            = "S0"
  max_size_gb         = 10
  tags                = var.tags
}
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.cleantest.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
