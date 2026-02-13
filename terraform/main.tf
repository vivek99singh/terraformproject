resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.network.subnet_ids[0]
  public_ip_id        = module.network.public_ip_id
  nsg_id              = module.network.nsg_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
}