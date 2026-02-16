resource "azurerm_mssql_server" "main" {
  name                         = "mssqlserver-${random_string.random.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "H@Sh1CoR3!"

  tags = var.tags
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_mssql_database" "main" {
  name           = "sqldatabase-${random_string.random.result}"
  server_id      = azurerm_mssql_server.main.id
  sku_name       = "S0"

  tags = var.tags
}