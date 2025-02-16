variable "location" { default = "koreacentral" }
variable "resource_group_name" { default = "rg-manoit-test" }
variable "vnet_name" { default = "vnet-manoit-test" }
variable "vnet_address_space" { default = ["10.0.0.0/16"] }
variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {
    "public_1"   = { address_prefixes = ["10.0.1.0/24"] },
    "public_2"   = { address_prefixes = ["10.0.2.0/24"] },
    "natprv_1"   = { address_prefixes = ["10.0.3.0/24"] },
    "natprv_2"   = { address_prefixes = ["10.0.4.0/24"] },
    "dbsubnet_1" = { address_prefixes = ["10.0.5.0/24"] },
    "dbsubnet_2" = { address_prefixes = ["10.0.6.0/24"] },
    "agwsubnet_1"= { address_prefixes = ["10.0.7.0/24"] },
    "agwsubnet_2"= { address_prefixes = ["10.0.8.0/24"] }
  }
}

variable "nsg_public_name"  { default = "nsg-public" }
variable "nsg_natprv_name"  { default = "nsg-natprv" }
variable "nsg_agw_name"     { default = "nsg-agw" }
variable "nsg_db_name"      { default = "nsg-db" }

variable "natgw_public_ip_name"  { default = "pip-natprv-1" }
variable "natgw_public_ip_sku"   { default = "Standard" }
variable "nat_gateway_name"      { default = "natgw-natprv-1" }
variable "nat_gateway_sku"       { default = "Standard" }
variable "nat_gateway_idle_timeout" { default = 5 }


/* instance 모듈 관련 변수 */
variable "instance_nic_name"           { default = "app-nic-1" }
variable "instance_ip_config_name"     { default = "internal" }
variable "instance_nsg_name"           { default = "nsg-natprv-nic" }
variable "instance_vm_name"            { default = "natprv-vm-1" }
variable "instance_vm_size"            { default = "Standard_DS1_v2" }
variable "instance_admin_username"     { default = "azureuser" }
variable "instance_os_disk_type"       { default = "StandardSSD_LRS" }
variable "instance_disk_size_gb"       { default = 64 }
variable "instance_zone"               { default = "1" }
variable "instance_image_publisher"    { default = "Canonical" }
variable "instance_image_offer"        { default = "0001-com-ubuntu-server-jammy" }
variable "instance_image_sku"          { default = "22_04-lts" }
variable "instance_image_version"      { default = "latest" }


# AKS
variable "aks_name" { default = "aks-manoit-test" }
variable "dns_prefix" { default = "aks-manoit" }
variable "private_cluster_enabled" { default = true }
variable "private_dns_zone_id" { default = "System" }
variable "network_plugin" { default = "azure" }
variable "network_policy" { default = "azure" }
variable "service_cidr" { default = "10.1.0.0/24" }
variable "dns_service_ip" { default = "10.1.0.10" }
variable "default_node_pool_name" { default = "default" }
variable "node_count" { default = 2 }
variable "vm_size" { default = "Standard_DS2_v2" }
variable "enable_auto_scaling" { default = false }
variable "rbac_enabled" { default = true }
variable "log_analytics_workspace_name" { default = "aks-log-workspace" }
variable "log_analytics_workspace_sku" { default = "PerGB2018" }
variable "log_analytics_retention_in_days" { default = 30 }



# ACR
variable "acr_name" { default = "acrmanoittest2" }
variable "acr_sku" { default = "Standard" }
variable "acr_admin_enabled" { default = false }

# Storage
variable "storage_account_name" { default = "manoitteststorage" }
variable "account_tier" { default = "Standard" }
variable "account_replication_type" { default = "LRS" }
variable "index_document" { default = "index.html" }
variable "error_404_document" { default = "index.html" }
variable "storage_container_name" { default = "container-manoit-test" }
variable "storage_container_access_type" { default = "blob" }

# OpenVPN
variable "openvpn_public_ip_name" { default = "pip-openvpn" }
variable "openvpn_public_ip_sku" { default = "Standard" }
variable "openvpn_nic_name" { default = "openvpn-nic" }
variable "openvpn_ip_config_name" { default = "openvpn-nic-config" }
variable "openvpn_nsg_name" { default = "nsg-openvpn" }
variable "openvpn_marketplace_publisher" { default = "openvpn" }
variable "openvpn_marketplace_offer" { default = "openvpnas" }
variable "openvpn_marketplace_plan" { default = "byol" }
variable "openvpn_vm_name" { default = "openvpn-test" }
variable "openvpn_vm_size" { default = "Standard_B1s" }
variable "openvpn_admin_username" { default = "azureuser" }
variable "openvpn_zone" { default = "1" }
variable "openvpn_image_publisher" { default = "openvpn" }
variable "openvpn_image_offer" { default = "openvpnas" }
variable "openvpn_image_sku" { default = "openvpnas" }
variable "openvpn_image_version" { default = "latest" }
variable "openvpn_plan_name" { default = "openvpnas" }
variable "openvpn_plan_product" { default = "openvpnas" }
variable "openvpn_plan_publisher" { default = "openvpn" }
variable "openvpn_os_disk_type" { default = "Premium_LRS" }

# Frontdoor
variable "frontdoor_profile_name" { default = "profile-manoit-test" }
variable "frontdoor_sku_name" { default = "Standard_AzureFrontDoor" }
variable "frontdoor_endpoint_name" { default = "endpoint-manoit" }
variable "frontdoor_origin_group_name" { default = "og-manoit-test" }
variable "frontdoor_lb_sample_size" { default = 4 }
variable "frontdoor_lb_successful_samples_required" { default = 3 }
variable "frontdoor_lb_additional_latency" { default = 50 }
variable "frontdoor_probe_path" { default = "/" }
variable "frontdoor_probe_request_type" { default = "GET" }
variable "frontdoor_probe_protocol" { default = "Https" }
variable "frontdoor_probe_interval" { default = 30 }
variable "frontdoor_origin_name" { default = "origin-manoit-test" }
# variable "frontdoor_origin_host_name" { default = "example.azurewebsites.net" }
# variable "frontdoor_origin_host_header" {default = ""}
variable "frontdoor_origin_http_port" { default = 80 }
variable "frontdoor_origin_https_port" { default = 443 }
variable "frontdoor_origin_priority" { default = 1 }
variable "frontdoor_origin_weight" { default = 1000 }
variable "frontdoor_route_name" { default = "route-manoit" }
variable "frontdoor_patterns_to_match" { default = ["/*"] }
variable "frontdoor_supported_protocols" { default = ["Http","Https"] }
variable "frontdoor_https_redirect_enabled" { default = true }


# DB 모듈 관련 변수
variable "db_dns_zone_name" { default = "db-manoit.private.mysql.database.azure.com" }
variable "db_dns_link_name" { default = "mysql-vnet-link" }
variable "mysql_server_name" { default = "db-manoit" }
variable "mysql_admin_login" { default = "jasonseo" }
variable "mysql_admin_password" { default = "Digital123!" }
variable "mysql_version" { default = "8.0.21" }
variable "mysql_sku_name" { default = "B_Standard_B1ms" }
variable "mysql_storage_size_gb" { default = 20 }
variable "mysql_backup_retention_days" { default = 7 }
variable "mysql_geo_redundant_backup_enabled" { default = false }