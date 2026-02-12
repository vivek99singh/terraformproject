resource "azurerm_virtual_network" "main" {
  name                = "vnet_main"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet_1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg_main"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "main" {
  name                = "publicip_main"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}