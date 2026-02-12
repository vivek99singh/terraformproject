resource "azurerm_network_interface" "main" {
  name                = "nic-southindia-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-southindia-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = random_password.admin.result
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}