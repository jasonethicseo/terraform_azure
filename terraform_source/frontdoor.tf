resource "azurerm_cdn_frontdoor_profile" "example" {
  name                = "my-cdnfd-profile"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "example" {
  name                     = "my-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id
}

resource "azurerm_cdn_frontdoor_origin_group" "example" {
  name                     = "my-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id

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

resource "azurerm_cdn_frontdoor_origin" "example" {
  name                          = "my-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id

  host_name  = "example.azurewebsites.net"
  http_port  = 80
  https_port = 443
  priority   = 1
  weight     = 1000

  certificate_name_check_enabled = false
}

resource "azurerm_cdn_frontdoor_route" "example" {
  name                          = "my-route"
#   cdn_frontdoor_profile_id      = azurerm_cdn_frontdoor_profile.example.id
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.example.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id
  cdn_frontdoor_origin_ids      = [
    azurerm_cdn_frontdoor_origin.example.id
  ]

  patterns_to_match   = ["/*"]
  supported_protocols = ["Https"]
  forwarding_protocol = "HttpsOnly"
  enabled             = true
}
