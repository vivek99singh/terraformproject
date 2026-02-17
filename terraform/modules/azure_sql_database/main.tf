resource "azurerm_mssql_server" "main" {
  name                         = "mssqlserver-${var.resource_group_name}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "main" {
  name                = "sqldatabase-${var.resource_group_name}"
  server_id           = azurerm_mssql_server.main.id
  sku_name            = "S0"
  max_size_gb         = 250
  tags                = var.tags
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}