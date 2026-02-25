resource "azurerm_network_interface" "main" {
  name                = "nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
  tags = var.tags
}

resource "random_password" "admin" {
  length  = 16
  special = true
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "winvm"
  location            = var.location
  resource_group_name = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  license_type        = "Windows_Server"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }
  tags = var.tags
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  lun                = 0
  caching    = "ReadWrite"
}