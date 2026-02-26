resource "azurerm_storage_account" "main" {
  name                     = "diagstorage${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}