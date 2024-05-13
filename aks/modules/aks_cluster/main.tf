
resource "azurerm_kubernetes_cluster" "k8s" {
    name                      = "${var.prefix}-cluster"
    location                  = var.location
    resource_group_name       = var.resource_group_name
    dns_prefix                = "${var.prefix}"
    node_resource_group       = "${var.prefix}-nodes-rg"
    kubernetes_version        = "${var.kubernetes_version}"
    private_cluster_enabled   = "${var.private_cluster_enabled}"
    sku_tier                  = "${var.sku_tier}"


    identity {
     type = "SystemAssigned"
    }

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
    
    #windows_profile {
    #admin_username = "your_username"
    #admin_password = "your_password"
 # }

    addon_profile {
        oms_agent {
          enabled = "${var.oms_agent.enabled}"
          #log_analytics_workspace_id = coalesce(var.oms_agent.log_analytics_workspace_id, var.log_analytics_workspace_id)
        }
        azure_policy {
          enabled = "${var.azure_policy.enabled}"
        }
    }

    tags = {
        Environment = "Development"
    }

    network_profile {
        network_plugin = "azure"
        service_cidr = "${var.service_cidr}"
        dns_service_ip = "${var.dns_service_ip}"
        docker_bridge_cidr = "${var.docker_bridge_cidr}"
        load_balancer_sku = "standard"
        outbound_type = "${var.outboundtype}"
    }
    default_node_pool {
      name                  = substr(var.default_node_pool.name, 0, 12)
      node_count            = "${var.default_node_pool.node_count}"
      max_count             = "${var.default_node_pool.max_count}"
      min_count             = "${var.default_node_pool.min_count}"
      vm_size               = "${var.default_node_pool.vm_size}"
      os_disk_size_gb       = "${var.default_node_pool.os_disk_size_gb}"
      vnet_subnet_id        = "${var.vnet_subnet_id}"
      max_pods              = "${var.default_node_pool.max_pods}"
      type                  = "${var.default_node_pool.agent_pool_type}"
      enable_node_public_ip = "${var.default_node_pool.enable_node_public_ip}"
      enable_auto_scaling   = "${var.default_node_pool.enable_auto_scaling}"
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
    availability_zones    = each.value.zones
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

    provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
    az aks get-credentials --resource-group "${var.prefix}-rg" --name "${var.prefix}-cluster" --overwrite-existing;
    EOS
     }
  }

resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
  name                       = "${azurerm_kubernetes_cluster.k8s.name}-audit"
  target_resource_id         = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "kube-apiserver"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-audit"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}





