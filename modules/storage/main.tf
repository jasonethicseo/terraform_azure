resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  static_website {
    index_document   = var.index_document
    error_404_document = var.error_404_document
  }
}

# resource "azurerm_storage_account_static_website" "static_website" {
#   storage_account_id = azurerm_storage_account.storage.id
#   index_document     = var.index_document
#   error_404_document = var.error_404_document
# }

resource "azurerm_storage_container" "blob_container" {
  name                  = var.container_name
  storage_account_id  = azurerm_storage_account.storage.id
  container_access_type = var.container_access_type
}
