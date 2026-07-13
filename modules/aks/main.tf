locals {
  name             = "${var.confident_application_name}-${var.confident_environment}"
  worker_pool_name = "${var.confident_region_prefix}${var.confident_application_code}${var.confident_environment_code}"
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${local.name}-aks-identity"
  location            = var.confident_azure_region
  resource_group_name = var.confident_resource_group_name
  tags                = var.confident_tags
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_user_assigned_identity.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                    = "${local.name}-aks"
  location                = var.confident_azure_region
  resource_group_name     = var.confident_resource_group_name
  dns_prefix              = local.name
  kubernetes_version      = var.confident_kubernetes_version
  private_cluster_enabled = !var.confident_public_aks

  # Workload Identity capability (the app itself uses the storage connection
  # string; this enables it for operators that opt in, e.g. ESO + Key Vault).
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name            = "system"
    vm_size         = "Standard_D4s_v5"
    node_count      = 2
    vnet_subnet_id  = var.confident_aks_subnet_id
    os_disk_size_gb = 100
    type            = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = length(var.confident_aks_admin_group_object_ids) > 0 ? [1] : []
    content {
      azure_rbac_enabled     = true
      admin_group_object_ids = var.confident_aks_admin_group_object_ids
    }
  }

  tags = var.confident_tags

  depends_on = [azurerm_role_assignment.aks_network_contributor]
}

resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  name                  = local.worker_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.confident_node_vm_size
  vnet_subnet_id        = var.confident_aks_subnet_id
  os_disk_size_gb       = 200

  auto_scaling_enabled = true
  min_count            = var.confident_node_group_min_size
  max_count            = var.confident_node_group_max_size
  node_count           = var.confident_node_group_desired_size

  tags = var.confident_tags
}
