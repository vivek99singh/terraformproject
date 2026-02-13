module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
}

module "vm" {
  source              = "./modules/vm"
  subnet_id           = module.network.subnet_ids[0]
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vm_size             = var.vm_size
  admin_username      = var.admin_username
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}