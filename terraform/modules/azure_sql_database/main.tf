resource "azurerm_mssql_server" "main" {
  name                         = "mssqlserver-${random_string.server_suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.password.result
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "main" {
  name                = "sqldatabase-${random_string.database_suffix.result}"
  server_id           = azurerm_mssql_server.main.id
  sku_name            = "S0"
  max_size_gb         = 5
  tags                = var.tags
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "whitelist_ip" {
  name             = "whitelist-ip"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "89.27.102.166"
  end_ip_address   = "89.27.102.166"
}

resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "database_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}