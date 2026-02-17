resource "azurerm_virtual_network" "main" {
  name                = "vnet-${random_string.vnet_suffix.result}"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  for_each = { for idx, cidr in var.subnet_cidrs : idx => cidr }
  name                 = "subnet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-${random_string.nsg_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow_rdp" {
  name                        = "allow-rdp"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_public_ip" "main" {
  name                = "pip-${random_string.pip_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "random_string" "vnet_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "nsg_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "pip_suffix" {
  length  = 8
  special = false
  upper   = false
}