resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg"
    location = "${var.location}"
}

data "azurerm_subnet" "existing_vnet_subnet" {
    name                 = "${var.subnet_name}"
    virtual_network_name = "${var.vnet_name}"
    resource_group_name  = "${var.network_rg}"
}

data "azurerm_resource_group" "vnet_rg" {
    name = "${var.network_rg}"
}


resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.prefix}-cluster"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = "${var.prefix}"
    node_resource_group = "${var.prefix}-nodes-rg"
    kubernetes_version  = "${var.kubernetes_version}"
    identity {
      type = "SystemAssigned"
    }
    linux_profile {
        admin_username = "azureuser"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
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

    service_principal {
        client_id     = "${var.sp_client_id}"
        client_secret = "${var.sp_client_secret}"
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
    }

    network_profile {
        network_plugin = "azure"
        service_cidr = "${var.service_cidr}"
        dns_service_ip = "${var.dns_service_ip}"
        docker_bridge_cidr = "${var.docker_bridge_cidr}"
        load_balancer_sku = "standard"
        outbound_type = "${var.outboundtype}"
    }

    tags = {
        Environment = "Development"
    }
}

  private_cluster_enabled = "${var.private_cluster}"

  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${self.name} --admin --overwrite-existing;
EOS



resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.k8s.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.test.location
    resource_group_name   = azurerm_resource_group.k8s.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
}