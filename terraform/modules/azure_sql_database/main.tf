resource "azurerm_resource_group" "sql_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${random_string.sql_server_suffix.result}"
  resource_group_name          = azurerm_resource_group.sql_rg.name
  location                     = azurerm_resource_group.sql_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result
  tags                         = var.tags
}

resource "azurerm_mssql_database" "sql_database" {
  name           = "sqldatabase-${random_string.sql_database_suffix.result}"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "GP_Gen5_2"
  tags           = var.tags
}

resource "random_string" "sql_server_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "sql_database_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "sql_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}