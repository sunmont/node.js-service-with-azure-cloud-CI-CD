# All Azure resources are conditional
resource "azurerm_resource_group" "rg" {
  count    = var.cloud == "azure" ? 1 : 0
  name     = "${var.cluster_name}-rg"
  location = var.azure_region
}

resource "azurerm_container_registry" "acr" {
  count               = var.cloud == "azure" ? 1 : 0
  name                = lower(replace("${var.cluster_name}acr${random_id.suffix.hex}", "-", ""))
  resource_group_name = azurerm_resource_group.rg[0].name
  location            = azurerm_resource_group.rg[0].location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "random_id" "suffix" {
  count       = var.cloud == "azure" ? 1 : 0
  byte_length = 3
}

resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.cloud == "azure" ? 1 : 0
  name                = "${var.cluster_name}-aks"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true
}
