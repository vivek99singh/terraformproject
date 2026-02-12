resource "azurerm_resource_group" "storage_rg" {
  name     = "storageResourceGroup"
  location = var.location
}

resource "azurerm_virtual_network" "storage_vnet" {
  name                = "storageVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.storage_rg.location
  resource_group_name = azurerm_resource_group.storage_rg.name
}

resource "azurerm_subnet" "storage_subnet" {
  name                 = "storageSubnet"
  resource_group_name  = azurerm_resource_group.storage_rg.name
  virtual_network_name = azurerm_virtual_network.storage_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "storage_nsg" {
  name                = "storageNSG"
  location            = azurerm_resource_group.storage_rg.location
  resource_group_name = azurerm_resource_group.storage_rg.name
}

resource "azurerm_subnet_network_security_group_association" "storage_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.storage_subnet.id
  network_security_group_id = azurerm_network_security_group.storage_nsg.id
}

resource "azurerm_public_ip" "storage_public_ip" {
  name                = "storagePublicIP"
  location            = azurerm_resource_group.storage_rg.location
  resource_group_name = azurerm_resource_group.storage_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "storage_nic" {
  name                = "storageNIC"
  location            = azurerm_resource_group.storage_rg.location
  resource_group_name = azurerm_resource_group.storage_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.storage_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.storage_public_ip.id
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "storageaccountunique"
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}