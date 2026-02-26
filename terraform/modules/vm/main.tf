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
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  network_interface_ids = [azurerm_network_interface.main.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
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

resource "azurerm_managed_disk" "data" {
  count                = length(var.additional_disks)
  name                 = "datadisk-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.additional_disks[count.index].type
  disk_size_gb         = var.additional_disks[count.index].size
  tags                 = var.tags
  create_option  = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count               = length(var.additional_disks)
  managed_disk_id     = azurerm_managed_disk.data[count.index].id
  virtual_machine_id  = azurerm_windows_virtual_machine.main.id
  lun                 = count.index
  caching    = "ReadWrite"
}