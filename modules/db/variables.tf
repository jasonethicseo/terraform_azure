variable "location" {
  description = "Azure region (예: koreacentral)"
  type        = string
}

variable "zone" {
  description = "Availability zone for the MySQL Flexible Server"
  type        = string
  default     = "2"  # 고정된 값 (예: "1")
}


variable "resource_group_name" {
  description = "Resource Group name for DB resources"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the virtual network to link with the private DNS zone"
  type        = string
}

variable "delegated_subnet_id" {
  description = "ID of the subnet delegated for the MySQL Flexible Server"
  type        = string
}

variable "dns_zone_name" {
  description = "Private DNS zone name"
  type        = string
  default     = "db-manoit.private.mysql.database.azure.com"
}

variable "dns_link_name" {
  description = "Name for the DNS zone virtual network link"
  type        = string
  default     = "mysql-vnet-link"
}

variable "mysql_server_name" {
  description = "Name for the MySQL Flexible Server"
  type        = string
  default     = "db-manoit"
}

variable "mysql_admin_login" {
  description = "Administrator login for MySQL"
  type        = string
  default     = "jasonseo"
}

variable "mysql_admin_password" {
  description = "Administrator password for MySQL"
  type        = string
  sensitive   = true
  default     = "Digital123!"  # 실제 배포 시에는 tfvars 파일로 안전하게 전달할 것
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0.21"
}

variable "mysql_sku_name" {
  description = "SKU name for MySQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "mysql_storage_size_gb" {
  description = "Storage size in GB for MySQL Flexible Server"
  type        = number
  default     = 20
}

variable "mysql_backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "mysql_geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = false
}
