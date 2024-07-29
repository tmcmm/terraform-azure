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
    default = "northeurope"
}

variable resource_group_name {
  description = "name of the resource group to deploy AKS cluster in"
  default     = "terraform"
}
######################### LOG ANALYTICS VARIABLES #######################################################

variable log_analytics_workspace_name {
  default = "MyLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable log_analytics_workspace_sku {
  default = "PerGB2018"
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

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
  default     = null
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
  default = "10.0.0.0/22"
}

variable "snetaddress_space" {
  description = "SNET CIDR"
  default = "10.0.0.0/23"
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
################# VIRTUAL MACHINE VARIABLES ############################################

variable "jumbox_enable" {
  description = "If you require a jumpbox VM to access your private cluster"
  type        = bool
  default     = true
}

variable "vm_vnet_name" {
  description = "Vnet name"
  default = "terraform-vnet-jumpbox"
}
variable "vm_subnet_name" {
  description = "Subnet name"
  default = "terraform-snet-jumpbox"
}

variable "vm_subnet_address_prefix" {
  description = "SNET CIDR Jumpbox"
  default = "10.0.3.0/25"
}

variable "vm_name" {
  description = "Specifies the name of the jumpbox virtual machine"
  default     = "JumpVM"
  type        = string
}

variable "jumpbox_vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  #default     = "standard_d2_v4"
  default     = "Standard_DS1_v2"
  type        = string
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
  default     = "Premium_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = true
  
}

variable "admin_username" {
  description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "azureuser"
}

variable "domain_name_label" {
  description = "Specifies the domain name for the jumbox virtual machine"
  default     = "jumpboxvm"
  type        = string
}

variable "script_name" {
  description = "(Required) Specifies the name of the custom script."
  type        = string
  default     = "configure-jumpbox-vm.sh"
}


################# CLUSTER VARIABLES ####################################################
variable "acr_id" {
  description = "ACR Resource ID"
  default = "Your ACR Resource ID"
}

variable "ssh_public_key" {
    description = "SSH Key"
    default = "~/.ssh/id_rsa.pub"
}
variable "ssh_private_key" {
    description = "SSH Key"
    default = "~/.ssh/id_rsa"
}

variable cluster_name {
    default = "k8sterraform"
}

variable "kubernetes_version" {
    description = "The Kubernetes version to use for the cluster."
    default =  "1.29.2"
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

variable "node_count" {
  description = "number of nodes to deploy"
  default     = 2
}

variable "vm_size" {
  description = "size/type of VM to use for system node pool"
  default     = "standard_d2_v4"
}

variable "extra_node_vm_size" {
  description = "size/type of VM to use for user node pool"
  default     = "standard_d2_v4"
}

variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
  default     = 128
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
  default     = "30"
}

variable "min_count" {
  default     = 1
  description = "Minimum Node Count"
}
variable "max_count" {
  default     = 2
  description = "Maximum Node Count"
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

variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = false
  type        = bool
}


variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = ["6exxxxx-0706e4403b77", "xxxxx-c58c-44b7-xxxx-ce1639c6c4f5"]
  type        = list(string)
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = false
  type        = bool
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition = contains( ["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

#Network Profile config
variable "network_plugin" {
  description = "network plugin for kubernetes network overlay (azure, calico, kubenet)"
  default     = "azure"
}

variable "keda_enabled" {
  description = "(Optional) Specifies whether KEDA Autoscaler can be used for workloads."
  type        = bool
  default     = false
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Specifies whether Vertical Pod Autoscaler should be enabled."
  type        = bool
  default     = false
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Microsoft Entra ID Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = false
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
  default     = false
}

variable "image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "Specifies the Azure Policy addon configuration."
  type        = object({
    enabled     = bool
  })
  default     = {
    enabled     = false
  }
}
variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}


###########################################################################################











