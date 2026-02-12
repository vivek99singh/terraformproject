output "vm_public_ip_address" {
  value = module.vm.public_ip_address
}

output "storage_account_primary_connection_string" {
  value = module.storage.primary_connection_string
}