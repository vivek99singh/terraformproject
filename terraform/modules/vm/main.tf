resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-southindia-${random_string.vm_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [var.network_interface_id]
  admin_password      = random_password.vm_password.result
  disable_password_authentication = false

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

resource "random_password" "vm_password" {
  length  = 16
  special = true
}

resource "random_string" "vm_suffix" {
  length  = 8
  special = false
  upper   = false
}