resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-southindia-${random_string.vnet_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-southindia-${random_string.subnet_suffix.result}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-southindia-${random_string.nsg_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-southindia-${random_string.nic_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_string" "vnet_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "subnet_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "nsg_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "nic_suffix" {
  length  = 8
  special = false
  upper   = false
}