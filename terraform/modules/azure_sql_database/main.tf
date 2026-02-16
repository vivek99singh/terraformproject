resource "azurerm_resource_group" "sql" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${random_string.random.result}"
  resource_group_name          = azurerm_resource_group.sql.name
  location                     = azurerm_resource_group.sql.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  minimum_tls_version          = "1.2"
  tags                         = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "sql_database" {
  name           = "sqldatabase-${random_string.random.result}"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "GP_Gen5_2"
  max_size_gb    = 10
  tags           = var.tags
}

resource "random_string" "random" {
  length  = 8
  special = false
  number  = true
}