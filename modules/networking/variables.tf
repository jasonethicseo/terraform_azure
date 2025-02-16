variable "location" {
  description = "Azure region (예: koreacentral)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name for networking resources"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets with their address prefixes. Keys should match: public_1, public_2, natprv_1, natprv_2, dbsubnet_1, dbsubnet_2, agwsubnet_1, agwsubnet_2"
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "nsg_public_name" {
  description = "Name for the public subnet NSG"
  type        = string
  default     = "nsg-public"
}

variable "nsg_natprv_name" {
  description = "Name for the NAT private subnet NSG"
  type        = string
  default     = "nsg-natprv"
}

variable "nsg_agw_name" {
  description = "Name for the application gateway NSG"
  type        = string
  default     = "nsg-agw"
}

variable "nsg_db_name" {
  description = "Name for the database subnet NSG"
  type        = string
  default     = "nsg-db"
}

/* NAT Gateway 관련 변수 */
variable "natgw_public_ip_name" {
  description = "Name for the NAT Gateway Public IP"
  type        = string
  default     = "pip-natprv-1"
}

variable "natgw_public_ip_sku" {
  description = "SKU for the NAT Gateway Public IP"
  type        = string
  default     = "Standard"
}

variable "nat_gateway_name" {
  description = "Name for the NAT Gateway"
  type        = string
  default     = "natgw-natprv-1"
}

variable "nat_gateway_sku" {
  description = "SKU name for the NAT Gateway"
  type        = string
  default     = "Standard"
}

variable "nat_gateway_idle_timeout" {
  description = "Idle timeout in minutes for the NAT Gateway"
  type        = number
  default     = 5
}
