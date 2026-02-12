module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.vm_resource_group.name
  location            = var.location
}

module "vm" {
  source              = "./modules/vm"
  subnet_id           = module.network.subnet_id
  public_ip_id        = module.network.public_ip_id
  nsg_id              = module.network.nsg_id
  resource_group_name = azurerm_resource_group.vm_resource_group.name
  location            = var.location
}

resource "azurerm_resource_group" "vm_resource_group" {
  name     = "rg-southindia-vm"
  location = var.location
}