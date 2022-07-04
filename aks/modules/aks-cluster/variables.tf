variable "dns_prefix" {
  description = "DNS prefix"
}

variable "prefix" {
  description = "The Prefix used for all Terraform VM resources"
  default = "aks-terraform"
}

variable "private_cluster" {
  description = "private cluster enabled"
  default=false
}


variable "location" {
  description = "azure location to deploy resources"
}

variable "cluster_name" {
  description = "AKS cluster name"
}

variable "resource_group_name" {
  description = "name of the resource group to deploy AKS cluster in"
}

variable "kubernetes_version" {
  description = "version of the kubernetes cluster"
}

variable "api_server_authorized_ip_ranges" {
  description = "ip ranges to lock down access to kubernetes api server"
  default     = "0.0.0.0/0"
}

# Node Pool config
variable "agent_pool_name" {
  description = "name for the agent pool profile"
  default     = "default"
}

variable "agent_pool_type" {
  description = "type of the agent pool (AvailabilitySet and VirtualMachineScaleSets)"
  default     = "VirtualMachineScaleSets"
}

variable "node_count" {
  description = "number of nodes to deploy"
}

variable "vm_size" {
  description = "size/type of VM to use for nodes"
}


variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
}

variable "vnet_subnet_id" {
  description = "vnet id where the nodes will be deployed"
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
}

#Network Profile config
variable "network_policy" {
  description = "network policy plugin for policy controller (azure or calico)"
  default     = "azure"
}

variable "network_plugin" {
  description = "network  plugin for kubernetes network overlay (azure or kubenet)"
  default     = "azure"
}
variable "service_cidr" {
  description = "kubernetes internal service cidr range"
  default     = "10.0.4.0/23"
}

variable "diagnostics_workspace_id" {
  description = "log analytics workspace id for cluster audit"
}
variable "client_id" {

}
variable "client_secret" {

}
variable "min_count" {
  default     = 1
  description = "Minimum Node Count"
}
variable "max_count" {
  default     = 5
  description = "Maximum Node Count"
}
variable "default_pool_name" {
  description = "name for the agent pool profile"
  default     = "system"
}
variable "default_pool_type" {
  description = "type of the agent pool (AvailabilitySet and VirtualMachineScaleSets)"
  default     = "VirtualMachineScaleSets"
}
variable "outboundtype" {
  description = "Outbound type connection for the AKS cluster - loadBalancer or userDefinedRouting"
  default = "loadBalancer"
}

variable "dns_service_ip" {
  description = "dns_service_ip"
  default = "10.0.4.10"
}
variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  default = "172.17.0.1/16"
}

variable "ssh_public_key" {
    description = "SSH Key"
    default = "~/.ssh/id_rsa.pub"
}

variable "default_node_pool" {
  description = "The object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones."
  type = object({
    name                           = string
    node_count                     = number
    node_os                        = string
    mode                           = string
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
      node_os = "Linux"
      vm_size = "Standard_D2s_v3"
      mode = "System"
      enable_auto_scaling = true
      enable_node_public_ip = false
      min_count = 1
      max_count = 5
      max_pods  = 100
      os_disk_size_gb = 128
      agent_pool_type = "VirtualMachineScaleSets"
  }
}
variable "additional_node_pools" {
  description = "The object to configure the second node pool with number of worker nodes, worker node VM size and Availability Zones."
  type = map(object({
    name                           = string
    zones                          = list(string)
    taints                         = list(string)
    node_count                     = number
    node_os                        = string
    mode                           = string
    vm_size                        = string
    enable_auto_scaling            = bool
    enable_node_public_ip          = bool
    min_count                      = number
    max_count                      = number
    max_pods                       = number
    os_disk_size_gb                = number
    agent_pool_type                = string
  }))
}



