# Variables file: variables.tf

variable "location" {
  description = "The Azure region to deploy the resources"
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "rg-vm-demo"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "Subnet prefix within the VNet"
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "The size of the VM"
  default     = "Standard_DS2_v2"
}

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  default     = "P@ssw0rd1234!"
}

# Resource Group
resource "azurerm_resource_group" "vm_demo" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vm_demo_vnet" {
  name                = "vnet-vm-demo"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.vm_demo.location
  resource_group_name = azurerm_resource_group.vm_demo.name
}

# Subnet
resource "azurerm_subnet" "vm_demo_subnet" {
  name                 = "subnet-vm-demo"
  resource_group_name  = azurerm_resource_group.vm_demo.name
  virtual_network_name = azurerm_virtual_network.vm_demo_vnet.name
  address_prefixes     = [var.subnet_prefix]
}

# Network Security Group
resource "azurerm_network_security_group" "vm_demo_nsg" {
  name                = "nsg-vm-demo"
  location            = azurerm_resource_group.vm_demo.location
  resource_group_name = azurerm_resource_group.vm_demo.name

  security_rule {
    name                       = "allow-ssh"
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

# Public IP
resource "azurerm_public_ip" "vm_demo_public_ip" {
  name                = "publicip-vm-demo"
  location            = azurerm_resource_group.vm_demo.location
  resource_group_name = azurerm_resource_group.vm_demo.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "vm_demo_nic" {
  name                = "nic-vm-demo"
  location            = azurerm_resource_group.vm_demo.location
  resource_group_name = azurerm_resource_group.vm_demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_demo_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_demo_public_ip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm_demo" {
  name                = "vm-demo"
  resource_group_name = azurerm_resource_group.vm_demo.name
  location            = azurerm_resource_group.vm_demo.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_demo_nic.id,
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
}

# Outputs

output "public_ip_address" {
  value = azurerm_public_ip.vm_demo_public_ip.ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm_demo.id
}