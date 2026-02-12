variable "location" {
  description = "The Azure region to deploy the resources"
  default     = "South India"
}

variable "address_space" {
  description = "The address space for the VNet"
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The CIDR subnet prefix for the subnet"
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "The size of the VM"
  default     = "Standard_DS3_v2" # Corresponds to 4 cores and 16GB RAM
}

resource "azurerm_resource_group" "example_rg" {
  name     = "example-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = azurerm_resource_group.example_rg.name
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = [var.subnet_prefix]
}

resource "azurerm_network_security_group" "example_nsg" {
  name                = "example-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.example_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

resource "azurerm_public_ip" "example_public_ip" {
  name                = "example-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example_nic" {
  name                = "example-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.example_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "example_vm" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  disable_password_authentication = true
}

output "public_ip_address" {
  value = azurerm_public_ip.example_public_ip.ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.example_vm.id
}