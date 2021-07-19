resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg"
    location = var.location
}

data "azurerm_virtual_network" "aks-vnet" {
    name                = "${var.vnet_name}"
    location   		= var.location
    resource_group_name = azurerm_resource_group.k8s.name
    address_space       = "${var.vnet_address_space}"
    
}

data "azurerm_subnet" "aks-subnet" {
    resource_group_name  = "${var.prefix}-rg"
    name                 = "${var.subnet_name}"
    virtual_network_name = "${var.vnet_name}"
    address_prefixes     = "${var.snetaddress_space}"
}


resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.prefix}-cluster"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
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
        client_id     = "${var.sp_client_id}"
        client_secret = "${var.sp_client_secret}"
    }

    addon_profile {
        oms_agent {
        enabled                    = false
        #log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
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
    # See https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration
    #role_based_access_control {
    #  azure_active_directory {
    #      client_app_id = var.client_app_id
    #      server_app_id =  var.server_app_id
    #      server_app_secret = var.server_app_secret
    #      tenant_id = var.tenant_id
    #  }
    #  enabled = true
  #}
  #resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
  #  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s_cluster.id
  #  name                  = substr(var.second_node_pool.name, 0, 12)
  #  node_count            = "${var.second_node_pool.node_count}"
  #  max_count             = "${var.second_node_pool.max_count}"
  #  min_count             = "${var.second_node_pool.min_count}"
  #  vm_size               = "${var.second_node_pool.vm_size}"
  #  os_disk_size_gb       = "${var.second_node_pool.os_disk_size_gb}"
  #  vnet_subnet_id        = "${var.vnet_subnet_id}"
  #  max_pods              = "${var.second_node_pool.max_pods}"
  #  type                  = "${var.second_node_pool.agent_pool_type}"
  #  enable_node_public_ip = "${var.second_node_pool.enable_node_public_ip}"
  #  enable_auto_scaling   = "${var.second_node_pool.enable_auto_scaling}"
  #  mode                  = "${var.second_node_pool.mode}"
  #  node_os               = "${var.second_node_pool.node_os}"
  #  }

    tags = {
        Environment = "Development"
    }

provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      az aks get-credentials --resource-group "${var.prefix}-rg" --name "${var.prefix}-cluster" --admin --overwrite-existing;
EOS

    }
}
