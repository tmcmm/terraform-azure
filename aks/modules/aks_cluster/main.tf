
resource "azurerm_kubernetes_cluster" "k8s" {
    name                             = "${var.prefix}-cluster-${var.network_plugin}"
    location                         = var.location
    resource_group_name              = var.resource_group_name
    dns_prefix                       = "${var.prefix}"
    node_resource_group              = "${var.prefix}-nodes-rg"
    kubernetes_version               = "${var.kubernetes_version}"
    private_cluster_enabled          = "${var.private_cluster_enabled}"
    sku_tier                         = "${var.sku_tier}"
    azure_policy_enabled             = "${var.azure_policy_enabled.enabled}"
    workload_identity_enabled        = "${var.workload_identity_enabled}"
    oidc_issuer_enabled              = "${var.oidc_issuer_enabled}"
    open_service_mesh_enabled        = "${var.open_service_mesh_enabled}"
    image_cleaner_enabled            = "${var.image_cleaner_enabled}"
    http_application_routing_enabled = "${var.http_application_routing_enabled}"

    identity {
     type = "SystemAssigned"
    }

    # identity {
    # type = "UserAssigned"
    # user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
    # }

    # service_principal {
    #   client_id     = "${var.client_id}"
    #   client_secret = "${var.client_secret}"
    # }

    linux_profile {
        admin_username = "azureuser"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }
    
    
  #   windows_profile {
  #     admin_username = "your_username"
  #     admin_password = "your_password"
  # }

    azure_active_directory_role_based_access_control  {
        managed                = true
        azure_rbac_enabled     = true
        tenant_id              = var.tenant_id
        admin_group_object_ids = var.admin_group_object_ids
        
  }

    workload_autoscaler_profile {
    keda_enabled                    = var.keda_enabled
    vertical_pod_autoscaler_enabled = var.vertical_pod_autoscaler_enabled
  }

    # oms_agent {
    #   # enabled = "${var.oms_agent.enabled}"
    #   log_analytics_workspace_id = coalesce(var.oms_agent.log_analytics_workspace_id, var.log_analytics_workspace_id)
    # }

    tags = {
        Environment = "Development"
    }

    network_profile {
        network_plugin = "${var.network_plugin}"
        service_cidr = "${var.service_cidr}"
        dns_service_ip = "${var.dns_service_ip}"
        outbound_type = "${var.outbound_type}"
    }
    default_node_pool {
      name                  = substr(var.default_node_pool.name, 0, 12)
      node_count            = "${var.default_node_pool.node_count}"
      max_count             = "${var.default_node_pool.max_count}"
      min_count             = "${var.default_node_pool.min_count}"
      vm_size               = "${var.default_node_pool.vm_size}"
      os_disk_size_gb       = "${var.default_node_pool.os_disk_size_gb}"
      os_disk_type          = "${var.default_node_pool.managed}"
      vnet_subnet_id        = "${var.vnet_subnet_id}"
      max_pods              = "${var.default_node_pool.max_pods}"
      type                  = "${var.default_node_pool.agent_pool_type}"
      enable_node_public_ip = "${var.default_node_pool.enable_node_public_ip}"
      enable_auto_scaling   = "${var.default_node_pool.enable_auto_scaling}"
      
    }
    
    lifecycle {
    ignore_changes = [
      kubernetes_version,
      tags
    ]
  }
}
  resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
    lifecycle {
    ignore_changes = [
      node_count
    ]
  }
    for_each = var.additional_node_pools

    kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
    name                  = each.value.node_os == "Windows" ? substr(each.key, 0, 6) : substr(each.key, 0, 12)
    zones                 = each.value.zones
    node_taints           = each.value.taints
    node_count            = each.value.node_count
    max_count             = each.value.max_count
    min_count             = each.value.min_count
    vm_size               = each.value.vm_size
    os_disk_size_gb       = each.value.os_disk_size_gb
    vnet_subnet_id        = "${var.vnet_subnet_id}"
    max_pods              = each.value.max_pods
    enable_node_public_ip = each.value.enable_node_public_ip
    enable_auto_scaling   = each.value.enable_auto_scaling
    mode                  = each.value.mode


  }
  # Conditionally execute the provisioner for non-private configuration
  resource "null_resource" "non_private" {
  depends_on = [azurerm_kubernetes_cluster.k8s]
  count = var.private_cluster_enabled ? 0 : 1

  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
    az aks get-credentials --resource-group "${var.prefix}-rg-${var.network_plugin}" --name "${var.prefix}-cluster-${var.network_plugin}" --overwrite-existing;
    EOS
    }
  }


# resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
#   name                            = "${azurerm_kubernetes_cluster.k8s.name}-audit"
#   log_analytics_workspace_id      = "${var.log_analytics_workspace_id}"
#   target_resource_id              = azurerm_kubernetes_cluster.k8s.id

#   enabled_log {
#     category = "kube-apiserver"
#   }

#   enabled_log {
#     category = "kube-controller-manager"
#   }

#   enabled_log {
#     category = "cluster-autoscaler"
#   }

#   enabled_log {
#     category = "kube-scheduler"
#   }

#   enabled_log {
#     category = "kube-audit"
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = false
#   }
# }

# resource "azurerm_storage_account" "example" {
#   name                = "storageaccountname"
#   resource_group_name = azurerm_resource_group.example.name
#   location                 = azurerm_resource_group.example.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind             = "BlobStorage"
# }

# resource "azurerm_storage_management_policy" "example" {
#   storage_account_id = azurerm_storage_account.example.id

#   rule {
#     name    = "aks-logs-retention"
#     enabled = true
#     filters {
#       prefix_match = ["log-files/AppServiceHTTPLogs"]
#       blob_types   = ["blockBlob"]
#     }
#     actions {
#       base_blob {
#         delete_after_days_since_modification_greater_than = 5
#       }
#     }
#   }
# }




