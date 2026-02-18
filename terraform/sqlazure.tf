# SQL Azure Database Resources
# This file contains Azure SQL Database infrastructure and dependencies

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_mssql_server" "main" {
  name                         = "finaltest-sql-server"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}
resource "azurerm_mssql_database" "main" {
  name                = "finaltest"
  server_id           = azurerm_mssql_server.main.id
  sku_name            = "S0"
  max_size_gb         = 5
  tags                = var.tags
}
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name      = "allow-azure-services"
  server_id = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
}
