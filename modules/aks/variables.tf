variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "aks_name" { type = string }
variable "dns_prefix" { type = string }
variable "private_cluster_enabled" { type = bool }
variable "private_dns_zone_id" { type = string }
variable "network_plugin" { type = string }
variable "network_policy" { type = string }
variable "service_cidr" { type = string }
variable "dns_service_ip" { type = string }
variable "default_node_pool_name" { type = string }
variable "node_count" { type = number }
variable "vm_size" { type = string }
variable "vnet_subnet_id" { type = string }
variable "enable_auto_scaling" { type = bool }
variable "rbac_enabled" { type = bool }
variable "log_analytics_workspace_id" { type = string }
# variable "extra_depends_on" {
#   description = "Extra dependencies for the AKS module (if needed)"
#   type        = list(any)
#   default     = []
# }
# variable "min_node_count" {
#   description = "Minimum number of nodes for auto scaling"
#   type        = number
#   default     = 1
# }
# variable "max_node_count" {
#   description = "Maximum number of nodes for auto scaling"
#   type        = number
#   default     = 3
# }

