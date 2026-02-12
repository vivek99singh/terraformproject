module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = var.location
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = var.location
  network_interface_id = module.network.network_interface_id
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = var.location
}

resource "azurerm_resource_group" "vm_rg" {
  name     = "rg-southindia-${random_string.rg_suffix.result}"
  location = var.location
}

resource "random_string" "rg_suffix" {
  length  = 8
  special = false
  upper   = false
}