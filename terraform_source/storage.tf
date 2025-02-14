resource "azurerm_storage_account" "storage" {
  name                     = "manoitteststorage"  # 고유한 이름으로 변경
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # 필요에 따라 GRS, ZRS 등으로 변경 가능

  static_website {
    index_document = "index.html"
    error_404_document = "index.html"
  }

  # 필요에 따라 다른 속성 추가 가능
  # enable_https_traffic_only = true
  # tags = {
  #   Environment = "Test"
  #   ManagedBy  = "Terraform"
  # }
}


resource "azurerm_storage_container" "blob_container" {
  name                  = "container-manoit-test"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"  # 필요에 따라 "container" 또는 "blob"으로 변경 가능
}
