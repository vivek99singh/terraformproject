resource "random_password" "admin" {
  length  = 16
  special = true
}

resource "azurerm_public_ip" "main" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = random_password.admin.result
  license_type          = "Windows_Server"
  tags                  = var.tags

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
}

resource "azurerm_managed_disk" "data" {
  count                = length(var.additional_disks)
  name                 = "${var.vm_name}-data-disk-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.additional_disks[count.index].size
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = length(var.additional_disks)
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  lun                = count.index
  caching    = "ReadWrite"
}