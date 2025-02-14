resource "azurerm_cdn_frontdoor_profile" "manoit_profile" {
  name                = "profile-manoit-test"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "manoit_endpoint" {
  name                     = "endpoint-manoit"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.manoit_profile.id
}

resource "azurerm_cdn_frontdoor_origin_group" "manoit_og" {
  name                     = "og-manoit-test"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.manoit_profile.id

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    path                = "/"
    request_type        = "GET"
    protocol            = "Https"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "manoit_origin" {
  name                          = "origin-manoit-test"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.manoit_og.id

  # 호스트 이름 (원본형식은 스토리지 정적 웹사이트)
  host_name = trim(
    replace(azurerm_storage_account.storage.primary_web_endpoint, "https://", ""),
    "/")

  # Storage 정적 웹사이트 호스트명으로 Host 헤더를 맞춰줌 (원본 호스트헤더)
  origin_host_header = trim(
    replace(azurerm_storage_account.storage.primary_web_endpoint, "https://", ""),
    "/"
  )

  http_port  = 80
  https_port = 443
  priority   = 1
  weight     = 1000

  certificate_name_check_enabled = false
  enabled = true  # 추가

  depends_on = [azurerm_storage_account.storage]

}

resource "azurerm_cdn_frontdoor_route" "manoit_route" {
  name                          = "route-manoit"
#   cdn_frontdoor_profile_id      = azurerm_cdn_frontdoor_profile.example.id
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.manoit_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.manoit_og.id
  cdn_frontdoor_origin_ids      = [
    azurerm_cdn_frontdoor_origin.manoit_origin.id
  ]

  patterns_to_match   = ["/*"]
  supported_protocols    = ["Http", "Https"]  
  https_redirect_enabled = true


  depends_on = [
    azurerm_cdn_frontdoor_origin_group.manoit_og,
    azurerm_cdn_frontdoor_origin.manoit_origin
  ]


}
