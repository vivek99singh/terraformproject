resource "azurerm_network_interface" "main" {
  name                = "nic-${var.resource_group_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-${var.resource_group_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  network_interface_ids = [azurerm_network_interface.main.id]
  tags                = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }
}

resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_managed_disk" "additional" {
  name                 = "additionaldisk-${var.resource_group_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "additional" {
  managed_disk_id    = azurerm_managed_disk.additional.id
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  lun                = 10
  caching            = "ReadWrite"
}