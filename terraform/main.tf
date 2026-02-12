module "storage_account" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.storage_rg.name
  storage_account_name = var.storage_account_name
  location            = var.location
}

resource "azurerm_resource_group" "storage_rg" {
  name     = var.resource_group_name
  location = var.location
}