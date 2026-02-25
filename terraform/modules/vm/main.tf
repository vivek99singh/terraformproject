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
  name                = "win-vm"
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
    disk_size_gb         = 256
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
  count                = length(var.additional_disks)
  name                 = "datadisk-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.additional_disks[count.index].size
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  count              = length(var.additional_disks)
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  lun                = count.index
  caching    = "ReadWrite"
}