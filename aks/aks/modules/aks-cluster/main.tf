
resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.prefix}-cluster"
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = "${var.prefix}"
    node_resource_group = "${var.prefix}-nodes-rg"
    kubernetes_version  = "${var.kubernetes_version}"
    private_cluster_enabled = "${var.private_cluster}"

   # identity {
    #  type = "SystemAssigned"
    #}
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

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    addon_profile {
        oms_agent {
          enabled = false
        #log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
        azure_policy {
          enabled = false
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
}
  resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
    kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
    name                  = substr(var.second_node_pool.name, 0, 12)
    node_count            = "${var.second_node_pool.node_count}"
    max_count             = "${var.second_node_pool.max_count}"
    min_count             = "${var.second_node_pool.min_count}"
    vm_size               = "${var.second_node_pool.vm_size}"
    os_disk_size_gb       = "${var.second_node_pool.os_disk_size_gb}"
    vnet_subnet_id        = "${var.vnet_subnet_id}"
    max_pods              = "${var.second_node_pool.max_pods}"
    enable_node_public_ip = "${var.second_node_pool.enable_node_public_ip}"
    enable_auto_scaling   = "${var.second_node_pool.enable_auto_scaling}"
    mode                  = "${var.second_node_pool.mode}"
    }


#output "lb_ip" {
#  value = kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.ip
#}

#provisioner "local-exec" {
#    # Load credentials to local environment so subsequent kubectl commands can be run
#    command = <<EOS
#      az aks get-credentials --resource-group "${var.prefix}-rg" --name "${var.prefix}-cluster" --admin --overwrite-existing;
#EOS
#
#    }
#
#
#resource "azurerm_kubernetes_cluster" "cluster" {
#  name                = var.cluster_name
#  location            = var.location
#  resource_group_name = var.resource_group_name
#  dns_prefix          = var.dns_prefix
#  kubernetes_version  = var.kubernetes_version
#
#  default_node_pool {
#    name            = var.default_pool_name
#    node_count      = var.node_count
#    vm_size         = var.vm_size
#    os_disk_size_gb = var.os_disk_size_gb
#    vnet_subnet_id  = var.vnet_subnet_id
#    max_pods        = var.max_pods
#    type            = var.default_pool_type
#
#    enable_auto_scaling = true
#    min_count           = var.min_count
#    max_count           = var.max_count
#
#    tags = merge(
#    {
#       "environment" = "runitoncloud"
#    },
#    {
#      "aadssh" = "True"
#    },
#  )
#  }
#
#
#  network_profile {
#    network_plugin     = var.network_plugin
#    network_policy     = "calico"
#    service_cidr       = var.service_cidr
#    dns_service_ip     = "10.0.0.10"
#    docker_bridge_cidr = "172.17.0.1/16"
#  }
#
#  service_principal {
#    client_id     = var.client_id
#    client_secret = var.client_secret
#  }
#
#
# tags = {
#        Environment = "Development"
#    }
#
#  lifecycle {
#    prevent_destroy = true
#  }
#}
#
resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
  name                       = "${azurerm_kubernetes_cluster.k8s.name}-audit"
  target_resource_id         = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id = var.diagnostics_workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

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



