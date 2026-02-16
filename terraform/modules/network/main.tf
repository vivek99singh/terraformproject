resource "azurerm_virtual_network" "main" {
  name                = "vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "azurerm_subnet" "main" {
  for_each             = toset(var.subnet_cidrs)
  name                 = "subnet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg"
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
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "azurerm_public_ip" "main" {
  name                = "publicip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}