resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg"
    location = var.location
}

# AKS Cluster Network
module "aks_network" {
  source              = "../modules/aks_network"
  subnet_name         = "${var.subnet_name}"
  vnet_name           = "${var.vnet_name}"
  resource_group_name = azurerm_resource_group.k8s.name
  subnet_cidr         = "${var.snetaddress_space}"
  location            = var.location
  address_space       = "${var.vnet_address_space}"
}

module "log_analytics" {
  source                           = "../modules/log_analytics"
  resource_group_name              = azurerm_resource_group.k8s.name
  log_analytics_workspace_location = var.log_analytics_workspace_location
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
}

# AKS Cluster
module "aks_cluster" {
  source                   = "../modules/aks-cluster"
  cluster_name             = "${var.prefix}-cluster"
  location                 = azurerm_resource_group.k8s.location
  dns_prefix               = "${var.prefix}"
  resource_group_name      = azurerm_resource_group.k8s.name
  kubernetes_version       = "${var.kubernetes_version}"
  vnet_subnet_id           = module.aks_network.aks_subnet_id
  min_count                = var.min_count
  max_count                = var.max_count
  node_count               = var.node_count
  vm_size                  = var.vm_size
  os_disk_size_gb          = "128"
  max_pods                 = "110"
  client_id                = var.client_id
  client_secret            = var.client_secret
  diagnostics_workspace_id = module.log_analytics.azurerm_log_analytics_workspace
}

