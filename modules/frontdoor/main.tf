resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = var.origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id

  load_balancing {
    sample_size                        = var.lb_sample_size
    successful_samples_required        = var.lb_successful_samples_required
    additional_latency_in_milliseconds = var.lb_additional_latency
  }

  health_probe {
    path                = var.probe_path
    request_type        = var.probe_request_type
    protocol            = var.probe_protocol
    interval_in_seconds = var.probe_interval
  }
}

locals {
  computed_origin = trim(replace(var.storage_primary_web_endpoint, "https://", ""), "/")
}


resource "azurerm_cdn_frontdoor_origin" "origin" {
  name                          = var.origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
 
 ##동적계산이 필요한 값
  host_name        = local.computed_origin 
  origin_host_header = local.computed_origin
 ##

  http_port                     = var.origin_http_port
  https_port                    = var.origin_https_port
  priority                      = var.origin_priority
  weight                        = var.origin_weight

  certificate_name_check_enabled = false
  enabled                        = true
}

resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = var.route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.origin.id]

  patterns_to_match       = var.patterns_to_match
  supported_protocols     = var.supported_protocols
  https_redirect_enabled  = var.https_redirect_enabled
}
