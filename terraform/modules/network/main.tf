resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Service     = "network-service"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "azurerm_subnet" "main" {
  for_each             = toset(var.subnet_cidrs)
  name                 = "subnet-${each.value}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-main"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "RDPAccess"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Service     = "nsg-service"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "azurerm_public_ip" "main" {
  name                = "publicip-main"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = {
    Environment = var.environment
    Service     = "publicip-service"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}