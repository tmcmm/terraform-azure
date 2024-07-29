resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg-${var.network_plugin}"
    location = "${var.location}"
}

# AKS Cluster Network
module "aks_network" {
  source              = "../modules/aks_network"
  resource_group_name = azurerm_resource_group.k8s.name
  vnet_name           = "${var.vnet_name}"
  location            = "${var.location}"
  address_space       = "${var.vnet_address_space}"

  subnets = [
    {
      name : "${var.subnet_name}"
      address_prefixes : "${[var.snetaddress_space]}"
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
    },
    {
      name : "${var.vm_subnet_name}"
      address_prefixes : "${[var.vm_subnet_address_prefix]}"
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
    }
  ]
}
# AKS Cluster
module "aks_cluster" {
  source                     = "../modules/aks_cluster"
  cluster_name               = "${var.prefix}-cluster-${var.network_plugin}"
  tenant_id                  = "${var.tenant_id}"
  location                   = azurerm_resource_group.k8s.location
  resource_group_name        = azurerm_resource_group.k8s.name
  dns_prefix                 = "${var.prefix}"
  kubernetes_version         = "${var.kubernetes_version}"
  vnet_subnet_id             = module.aks_network.aks_subnet_id[var.subnet_name]
  network_plugin             = "${var.network_plugin}"
  private_cluster_enabled    = "${var.private_cluster_enabled}"
  automatic_channel_upgrade  = var.automatic_channel_upgrade
  client_id                  = var.client_id
  client_secret              = var.client_secret
  min_count                  = var.min_count
  max_count                  = var.max_count
  node_count                 = var.node_count
  vm_size                    = var.vm_size
  os_disk_size_gb            = "128"
  max_pods                   = "30"
  outbound_type              = "loadBalancer"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  keda_enabled               = var.keda_enabled
  vertical_pod_autoscaler_enabled  = var.vertical_pod_autoscaler_enabled
  workload_identity_enabled  = var.workload_identity_enabled
  oidc_issuer_enabled        = var.oidc_issuer_enabled
  open_service_mesh_enabled  = var.open_service_mesh_enabled
  image_cleaner_enabled      = var.image_cleaner_enabled
  azure_policy_enabled       = var.azure_policy_enabled
  http_application_routing_enabled = var.http_application_routing_enabled
  
  additional_node_pools = {
    usernpool = {
      name = "usernpool"
      zones = null
      taints = null
      node_count = 1
      node_os = "Linux"
      vm_size = "${var.extra_node_vm_size}"
      mode = "User"
      enable_auto_scaling = true
      enable_node_public_ip = false
      min_count = 1
      max_count = 2
      max_pods  = 30
      os_disk_size_gb = 128
      agent_pool_type = "VirtualMachineScaleSets"
    }
  }
}

# Generate randon name for virtual machine
 resource "random_string" "virtual_machine_name" {
   length  = 8
   special = false
   lower   = true
   upper   = false
   numeric  = false
}


 module "virtual_machine" {
  count = var.jumbox_enable ? 1 : 0
  source                              = "../modules/virtual_machine"
  name                                = "${var.vm_name}-${random_string.virtual_machine_name.result}"
  size                                = var.jumpbox_vm_size
  location                            = azurerm_resource_group.k8s.location
  public_ip                           = var.vm_public_ip
  #public_ip                           = length(azurerm_public_ip.public_ip) > 0 ? azurerm_public_ip.public_ip[0].ip_address : ""
  vm_user                             = var.admin_username
  admin_ssh_public_key                = var.ssh_public_key
  os_disk_image                       = var.vm_os_disk_image
  domain_name_label                   = var.domain_name_label
  subnet_id                           = module.aks_network.aks_subnet_id[var.vm_subnet_name]
  resource_group_name                 = azurerm_resource_group.k8s.name
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  script_name                         = var.script_name

}

# Conditionally execute the provisioner for private configuration
 resource "null_resource" "private" {
 depends_on = [
  module.aks_cluster,
  module.virtual_machine
  ]  

  provisioner "remote-exec" {
    inline = [
      "az login --use-device",
      "az account set --subscription ${var.subscription_id}",
      "az aks get-credentials --resource-group ${var.prefix}-rg-private --name ${var.prefix}-cluster-private --overwrite-existing"
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
  #    host        = var.vm_public_ip
      host        = element(flatten(module.virtual_machine[*].public_ip), 0)
      private_key = file(var.ssh_private_key)
    }
  }
}



# module "log_analytics" {
#   source                           = "../modules/log_analytics"
#   resource_group_name              = azurerm_resource_group.k8s.name
#   log_analytics_workspace_location = var.log_analytics_workspace_location
#   log_analytics_workspace_name     = var.log_analytics_workspace_name
#   log_analytics_workspace_sku      = var.log_analytics_workspace_sku
# }
