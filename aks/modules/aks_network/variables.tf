variable "subnet_name" {
  description = "name to give the subnet"
}

variable "resource_group_name" {
  description = "resource group that the vnet resides in"
}

variable "vnet_name" {
  description = "name of the vnet that this subnet will belong to"
  default     = "vnet"
}

variable "subnet_cidr" {
  description = "the subnet cidr range"
  
}

variable "location" {
  description = "the cluster location"
}

variable "address_space" {
  description = "Network address space"
}

variable "nsg_name" {
  description = "Nsg Rule name"
  default     = "nsg-port-22"
}

variable "vnet_address_space" {
  description = "VNET CIDR"
  default = "10.0.0.0/23"
}

variable "snetaddress_space" {
  description = "SNET CIDR"
  default = "10.0.0.0/24"
}

variable "service_cidr" {
  description = "Service CIDR"
  default = "10.0.4.0/23"
}
variable "dns_service_ip" {
  description = "dns_service_ip"
  default = "10.0.4.10"
}
variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  default = "172.17.0.1/16"
}
