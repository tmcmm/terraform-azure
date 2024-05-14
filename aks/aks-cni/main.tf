resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg"
    location = "${var.location}"
}

# AKS Cluster Network
module "aks_network" {
  source              = "../modules/aks_network"
  subnet_name         = "${var.subnet_name}"
  vnet_name           = "${var.vnet_name}"
  resource_group_name = azurerm_resource_group.k8s.name
  subnet_cidr         = "${var.snetaddress_space}"
  location            = "${var.location}"
  address_space       = "${var.vnet_address_space}"
}

# module "log_analytics" {
#   source                           = "../modules/log_analytics"
#   resource_group_name              = azurerm_resource_group.k8s.name
#   log_analytics_workspace_location = var.log_analytics_workspace_location
#   log_analytics_workspace_name     = var.log_analytics_workspace_name
#   log_analytics_workspace_sku      = var.log_analytics_workspace_sku
# }

# AKS Cluster
module "aks_cluster" {
  source                     = "../modules/aks_cluster"
  cluster_name               = "${var.prefix}-cluster"
  tenant_id                  = "${var.tenant_id}"
  location                   = azurerm_resource_group.k8s.location
  resource_group_name        = azurerm_resource_group.k8s.name
  dns_prefix                 = "${var.prefix}"
  kubernetes_version         = "${var.kubernetes_version}"
  vnet_subnet_id             = module.aks_network.aks_subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  automatic_channel_upgrade  = var.automatic_channel_upgrade
  client_id                  = var.client_id
  client_secret              = var.client_secret
  min_count                  = var.min_count
  max_count                  = var.max_count
  node_count                 = var.node_count
  vm_size                    = var.vm_size
  os_disk_size_gb            = "128"
  max_pods                   = "30"
  
  additional_node_pools = {
    usernpool = {
      name = "usernpool"
      zones = null
      taints = null
      node_count = 1
      node_os = "Linux"
      vm_size = "Standard_D2s_v3"
      mode = "User"
      enable_auto_scaling = true
      enable_node_public_ip = false
      min_count = 1
      max_count = 5
      max_pods  = 30
      os_disk_size_gb = 128
      agent_pool_type = "VirtualMachineScaleSets"
    }
  }
}

module "virtual_machine" {
  source                              = "../modules/virtual_machine"
  name                                = var.vm_name
  size                                = var.vm_size
  location                            = var.location
  public_ip                           = var.vm_public_ip
  vm_user                             = var.admin_username
  admin_ssh_public_key                = var.ssh_public_key
  os_disk_image                       = var.vm_os_disk_image
  domain_name_label                   = var.domain_name_label
  resource_group_name                 = azurerm_resource_group.rg.name
  subnet_id                           = module.aks_network.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  script_name                         = var.script_name
}

