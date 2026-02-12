module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.resource.name
  location            = var.location
  vnet_cidr           = var.vnet_cidr
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.resource.name
  location            = var.location
  network_interface_ids = [module.network.network_interface_id]
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.resource.name
  location            = var.location
}

resource "azurerm_resource_group" "resource" {
  name     = "rg-${var.resource_name}"
  location = var.location
}