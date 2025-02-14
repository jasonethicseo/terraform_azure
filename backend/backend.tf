# Terraform 버전 및 제공자 설정
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.64.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Terraform 상태를 저장할 리소스 그룹 생성
resource "azurerm_resource_group" "tf_backend" {
  name     = "rg-terraform-backend"
  location = "Korea Central"  # 원하는 Azure 지역으로 변경
}

# Terraform 상태를 저장할 Storage Account 생성
resource "azurerm_storage_account" "tf_state" {
  name                     = "manoittesttfstate"  # 반드시 전역에서 유일한 이름 (소문자, 숫자만)
  resource_group_name      = azurerm_resource_group.tf_backend.name
  location                 = azurerm_resource_group.tf_backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  https_traffic_only_enabled = true
  min_tls_version           = "TLS1_2"
}

# Terraform 상태를 저장할 Blob Container 생성
resource "azurerm_storage_container" "tf_state_container" {
  name                  = "tfstate-manoit-blob"   # 컨테이너 이름 (원하는 이름으로 변경 가능)
  storage_account_name  = azurerm_storage_account.tf_state.name
  container_access_type = "private"
}
