resource_group_name = "rg-windows-vm"
location            = "eastus"
vnet_cidr           = "10.0.0.0/16"
subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
vm_size             = "Standard_D2s_v5"
admin_username      = "adminuser"