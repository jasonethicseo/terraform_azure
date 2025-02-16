terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "manoittesttfstate"
    container_name       = "tfstate-manoit-blob"
    key                  = "dev/terraform/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "2a97ef2f-0b8f-4305-9f97-efeecaee06b5"
}

module "networking" {
  source              = "../../modules/networking"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets

  nsg_public_name = var.nsg_public_name
  nsg_natprv_name = var.nsg_natprv_name
  nsg_agw_name    = var.nsg_agw_name
  nsg_db_name     = var.nsg_db_name

  natgw_public_ip_name    = var.natgw_public_ip_name
  natgw_public_ip_sku     = var.natgw_public_ip_sku
  nat_gateway_name        = var.nat_gateway_name
  nat_gateway_sku         = var.nat_gateway_sku
  nat_gateway_idle_timeout = var.nat_gateway_idle_timeout
}

module "log_analytics" {
  source              = "../../modules/log_analytics"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  workspace_name      = var.log_analytics_workspace_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_in_days
}

module "instance" {
  source              = "../../modules/instance"
  location            = var.location
  resource_group_name       = module.networking.resource_group_name
  subnet_id           = module.networking.subnet_ids["natprv_1"]
  nic_name            = var.instance_nic_name
  ip_config_name      = var.instance_ip_config_name
  nsg_name            = var.instance_nsg_name

  vm_name             = var.instance_vm_name
  vm_size             = var.instance_vm_size
  admin_username      = var.instance_admin_username
  admin_ssh_public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  os_disk_type        = var.instance_os_disk_type
  disk_size_gb        = var.instance_disk_size_gb
  zone                = var.instance_zone

  image_publisher     = var.instance_image_publisher
  image_offer         = var.instance_image_offer
  image_sku           = var.instance_image_sku
  image_version       = var.instance_image_version
}


module "aks" {
  source                    = "../../modules/aks"
  location                  = var.location
  resource_group_name       = module.networking.resource_group_name
  aks_name                  = var.aks_name
  dns_prefix                = var.dns_prefix
  private_cluster_enabled   = var.private_cluster_enabled
  private_dns_zone_id       = var.private_dns_zone_id
  network_plugin            = var.network_plugin
  network_policy            = var.network_policy
  service_cidr              = var.service_cidr
  dns_service_ip            = var.dns_service_ip
  default_node_pool_name    = var.default_node_pool_name
  node_count                = var.node_count
  vm_size                   = var.vm_size
  vnet_subnet_id            = module.networking.subnet_ids["natprv_2"]
  enable_auto_scaling       = var.enable_auto_scaling
  rbac_enabled              = var.rbac_enabled
  log_analytics_workspace_id = module.log_analytics.workspace_id
  depends_on = [module.networking]
}

module "acr" {
  source              = "../../modules/acr"
  acr_name            = var.acr_name
  resource_group_name    = module.networking.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  aks_principal_id    = module.aks.principal_id
}

module "storage" {
  source                 = "../../modules/storage"
  storage_account_name   = var.storage_account_name
  resource_group_name    = module.networking.resource_group_name
  location               = var.location
  account_tier           = var.account_tier
  account_replication_type = var.account_replication_type
  index_document         = var.index_document
  error_404_document     = var.error_404_document
  container_name         = var.storage_container_name
  container_access_type  = var.storage_container_access_type
}

data "azurerm_key_vault" "key_vault" {
  name                = "manoit-test-key2"           # Key Vault 이름
  resource_group_name = "rg-manoit-keys"            # 리소스 그룹 이름
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "0206-test-key"                      # 비밀 이름
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

module "openvpn" {
  source                  = "../../modules/openvpn"
  public_ip_name          = var.openvpn_public_ip_name
  resource_group_name    = module.networking.resource_group_name
  location                = var.location
  public_ip_sku           = var.openvpn_public_ip_sku
  nic_name                = var.openvpn_nic_name
  ip_config_name          = var.openvpn_ip_config_name
  subnet_id               = module.networking.subnet_ids["public_1"]
  nsg_name                = var.openvpn_nsg_name
  marketplace_publisher   = var.openvpn_marketplace_publisher
  marketplace_offer       = var.openvpn_marketplace_offer
  marketplace_plan        = var.openvpn_marketplace_plan
  vm_name                 = var.openvpn_vm_name
  vm_size                 = var.openvpn_vm_size
  admin_username          = var.openvpn_admin_username
  zone                    = var.openvpn_zone
  image_publisher         = var.openvpn_image_publisher
  image_offer             = var.openvpn_image_offer
  image_sku               = var.openvpn_image_sku
  image_version           = var.openvpn_image_version
  plan_name               = var.openvpn_plan_name
  plan_product            = var.openvpn_plan_product
  plan_publisher          = var.openvpn_plan_publisher
  admin_ssh_public_key    = data.azurerm_key_vault_secret.ssh_public_key.value
  os_disk_type            = var.openvpn_os_disk_type
}

module "frontdoor" {
  source                   = "../../modules/frontdoor"
  profile_name             = var.frontdoor_profile_name
  resource_group_name    = module.networking.resource_group_name
  sku_name                 = var.frontdoor_sku_name
  endpoint_name            = var.frontdoor_endpoint_name
  origin_group_name        = var.frontdoor_origin_group_name
  lb_sample_size           = var.frontdoor_lb_sample_size
  lb_successful_samples_required = var.frontdoor_lb_successful_samples_required
  lb_additional_latency    = var.frontdoor_lb_additional_latency
  probe_path               = var.frontdoor_probe_path
  probe_request_type       = var.frontdoor_probe_request_type
  probe_protocol           = var.frontdoor_probe_protocol
  probe_interval           = var.frontdoor_probe_interval
  origin_name              = var.frontdoor_origin_name
  # origin_host_name         = var.frontdoor_origin_host_name
  # origin_host_header       = var.frontdoor_origin_host_header
  origin_http_port         = var.frontdoor_origin_http_port
  origin_https_port        = var.frontdoor_origin_https_port
  origin_priority          = var.frontdoor_origin_priority
  origin_weight            = var.frontdoor_origin_weight
  route_name               = var.frontdoor_route_name
  patterns_to_match        = var.frontdoor_patterns_to_match
  supported_protocols      = var.frontdoor_supported_protocols
  https_redirect_enabled   = var.frontdoor_https_redirect_enabled

  storage_primary_web_endpoint = module.storage.primary_web_endpoint
}


module "db" {
  source                = "../../modules/db"
  location              = var.location
  resource_group_name    = module.networking.resource_group_name
  virtual_network_id    = module.networking.vnet_id
  delegated_subnet_id   = module.networking.subnet_ids["dbsubnet_1"]
  dns_zone_name         = var.db_dns_zone_name
  dns_link_name         = var.db_dns_link_name
  mysql_server_name     = var.mysql_server_name
  mysql_admin_login     = var.mysql_admin_login
  mysql_admin_password  = var.mysql_admin_password
  mysql_version         = var.mysql_version
  mysql_sku_name        = var.mysql_sku_name
  mysql_storage_size_gb = var.mysql_storage_size_gb
  mysql_backup_retention_days = var.mysql_backup_retention_days
  mysql_geo_redundant_backup_enabled = var.mysql_geo_redundant_backup_enabled
}