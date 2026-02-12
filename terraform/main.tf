module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
}

module "vm" {
  source              = "./modules/vm"
  subnet_id           = module.network.subnet_id
  public_ip_id        = module.network.public_ip_id
  nsg_id              = module.network.nsg_id
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}