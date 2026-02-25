resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "admin_password" {
  length  = 16
  special = true
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_mssql_server" "main" {
  name                         = "mssqlserver${random_string.server_suffix.result}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.admin_password.result
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "main" {
  name      = "sqldb-${random_string.server_suffix.result}"
  server_id = azurerm_mssql_server.main.id
  sku_name  = "S0"
  tags      = var.tags
  transparent_data_encryption_enabled = true
}

resource "azurerm_mssql_firewall_rule" "allow_specific_ip" {
  name      = "allow-specific-ip"
  server_id = azurerm_mssql_server.main.id
  start_ip_address = "129.41.46.1"
  end_ip_address   = "129.41.46.1"
}