############################ ACCOUNT VARIABLES #############################
variable "sp_client_id" {
  description = "The service principal id of client app. AKS uses this SP to create the required resources."
  default     = ""
}

variable "sp_client_secret" {
  description = "Service Principle Client Secret for AKS cluster (not used if using Managed Identity)"
  default = ""
}


############################ GENERAL VARIABLES #############################
variable "prefix" {
  description = "The Prefix used for all Terraform VM resources"
  default = "aks-tf"
}

variable location {
    default = "westeurope"
}

################ Networking variables ######################################
variable "network_rg" {
  description = "Existing network resource group"
  default = "azure-terraform-net-rg"
}

variable "vnet_name" {
  description = "Existing vnet name"
  default = "terraform-vnet"
}
variable "subnet_name" {
  description = "Existing subnet name"
  default = "terraform-snet"
}

variable "outboundtype" {
  description = "Service Principle Client Secret for AKS cluster (not used if using Managed Identity)"
  default = "loadBalancer"
}

variable "service_cidr" {
  description = "Service CIDR"
  default = "10.211.0.0/16"
}
variable "dns_service_ip" {
  description = "dns_service_ip"
  default = "10.211.0.10"
}
variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  default = "172.17.0.1/16"
}

################# CLUSTER VARIABLES ##########################################
variable "acr_id" {
  description = "ACR Resource ID"
  default = "Your ACR Resource ID"
}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    description = "SSH Key"
    default = "~/.ssh/id_rsa.pub"
}

variable cluster_name {
    default = "k8sterraform"
}

variable "kubernetes_version" {
    description = "The Kubernetes version to use for the cluster."
    default =  "1.20.5"
}

variable "private_cluster" {
  description = "private cluster enabled"
  default=false
}

variable "default_node_pool" {
  description = "The object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones."
  type = object({
    name                           = string
    node_count                     = number
    vm_size                        = string
    enable_auto_scaling            = bool
    min_count                      = number
    max_count                      = number
    enable_node_public_ip          = bool
    max_pods                       = number
    os_disk_size_gb                = number
    agent_pool_type                = string
  })
  default = {
      name = "systemnpool"
      node_count = 2
      vm_size = "Standard_D2s_v3"
      enable_auto_scaling = true
      enable_node_public_ip = false
      min_count = 1
      max_count = 5
      max_pods  = 100
      os_disk_size_gb = 128
      agent_pool_type = "VirtualMachineScaleSets"
  }
}




########################## LOG ANALYTICS VARIABLES #############################################

variable log_analytics_workspace_name {
    default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}


