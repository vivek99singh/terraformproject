module "azure_sql_database" {
  source               = "./modules/azure_sql_database"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  tags                 = var.tags
}

resource "azurerm_resource_group" "main" {
  name     = "resource-group-sql"
  location = "eastus"
  tags     = var.tags
}