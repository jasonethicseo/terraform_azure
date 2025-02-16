variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for compute resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to attach the NIC"
  type        = string
}

variable "nic_name" {
  description = "Name for the network interface"
  type        = string
}

variable "ip_config_name" {
  description = "Name for the NIC IP configuration"
  type        = string
}

variable "nsg_name" {
  description = "Name for the NSG associated with the NIC"
  type        = string
}

variable "vm_name" {
  description = "Name for the Linux virtual machine"
  type        = string
}

variable "vm_size" {
  description = "VM size (e.g., Standard_DS1_v2)"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the admin user"
  type        = string
}

variable "os_disk_type" {
  description = "Storage account type for OS disk (e.g., StandardSSD_LRS)"
  type        = string
}

variable "disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
}

variable "zone" {
  description = "Availability zone for the VM"
  type        = string
}

variable "image_publisher" {
  description = "Publisher for the OS image"
  type        = string
}

variable "image_offer" {
  description = "Offer for the OS image"
  type        = string
}

variable "image_sku" {
  description = "SKU for the OS image"
  type        = string
}

variable "image_version" {
  description = "Version for the OS image"
  type        = string
}
