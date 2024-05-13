############################ ACCOUNT VARIABLES #############################
variable "client_id" {
  description = "The service principal id of client app. AKS uses this SP to create the required resources."
}

variable "client_secret" {
  description = "Service Principle Client Secret for AKS cluster (not used if using Managed Identity)"
}

variable "subscription_id" {
  description = "The subscription id from your account - az account show --subscription subsname --query id --output tsv"
}

variable "tenant_id" {
  description = "The tenant ID from your account - az account show --subscription subsname --query tenantId --output tsv"
}
##############################################################################

############################ GENERAL VARIABLES #############################
variable "prefix" {
  description = "The Prefix used for all Terraform VM resources"
  default = "aks-terraform"
}

variable "location" {
    default = "westeurope"
}

variable resource_group_name {
  description = "name of the resource group to deploy AKS cluster in"
  default     = "terraform"
}
######################### LOG ANALYTICS VARIABLES #######################################################

variable log_analytics_workspace_name {
  default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}
################ Networking variables #######################################################################

variable "vnet_name" {
  description = "Vnet name"
  default = "terraform-vnet"
}
variable "subnet_name" {
  description = "Subnet name"
  default = "terraform-snet"
}

variable "outboundtype" {
  description = "Outbound type connection for the AKS cluster - loadBalancer or userDefinedRouting"
  default = "loadBalancer"
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
########################################################################################


################# CLUSTER VARIABLES ##########################################
variable "acr_id" {
  description = "ACR Resource ID"
  default = "Your ACR Resource ID"
}

variable "ssh_public_key" {
    description = "SSH Key"
    default = "~/.ssh/id_ed25519.pub"
}

variable cluster_name {
    default = "k8sterraform"
}

variable "kubernetes_version" {
    description = "The Kubernetes version to use for the cluster."
    default =  "1.29.0"
}

variable "private_cluster" {
  description = "private cluster enabled"
  default = false
}

variable "node_count" {
  description = "number of nodes to deploy"
  default     = 2
}

variable "vm_size" {
  description = "size/type of VM to use for nodes"
  default     = "Standard_D2_v2"
}
variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
  default     = 128
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
  default     = "100"
}

variable "min_count" {
  default     = 1
  description = "Minimum Node Count"
}
variable "max_count" {
  default     = 2
  description = "Maximum Node Count"
}
variable "oms_agent" {
  description = "Specifies the OMS agent addon configuration."
  type        = object({
    enabled                     = bool           
    log_analytics_workspace_id  = string
  })
  default     = {
    enabled                     = false
    log_analytics_workspace_id  = null
  }
}

variable "azure_policy" {
  description = "Specifies the Azure Policy addon configuration."
  type        = object({
    enabled     = bool
  })
  default     = {
    enabled     = false
  }
}
variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
  default     = null
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, and stable."
  default     = "stable"
  type        = string

  validation {
    condition = contains( ["patch", "rapid", "stable"], var.automatic_channel_upgrade)
    error_message = "The upgrade mode is invalid."
  }
}

###########################################################################################










