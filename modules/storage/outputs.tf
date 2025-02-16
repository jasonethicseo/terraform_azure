output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}

output "primary_web_endpoint" {
  value = azurerm_storage_account.storage.primary_web_endpoint
}
