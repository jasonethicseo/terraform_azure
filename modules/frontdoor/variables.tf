variable "profile_name" { type = string }
variable "resource_group_name" { type = string }
variable "sku_name" { type = string }
variable "endpoint_name" { type = string }
variable "origin_group_name" { type = string }
variable "lb_sample_size" { type = number }
variable "lb_successful_samples_required" { type = number }
variable "lb_additional_latency" { type = number }
variable "probe_path" { type = string }
variable "probe_request_type" { type = string }
variable "probe_protocol" { type = string }
variable "probe_interval" { type = number }
variable "origin_name" { type = string }
# variable "origin_host_name" { type = string }
# variable "origin_host_header" { type = string}
variable "origin_http_port" { type = number }
variable "origin_https_port" { type = number }
variable "origin_priority" { type = number }
variable "origin_weight" { type = number }
variable "route_name" { type = string }
variable "patterns_to_match" { type = list(string) }
variable "supported_protocols" { type = list(string) }
variable "https_redirect_enabled" { type = bool }
variable "storage_primary_web_endpoint" {
  description = "The primary web endpoint of the storage account hosting the static website."
  type        = string
}