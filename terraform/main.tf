terraform {
  required_version = "~> 1.0"

  
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.5"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  location = "Canada East"
  name     = "luis-ticktes"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app" {
  location = local.location
  name     = local.name
}

resource "azurerm_kubernetes_cluster" "app" {
  location            = local.location
  name                = local.name
  resource_group_name = azurerm_resource_group.app.name
  dns_prefix          = "aks-dns-${local.name}"

  default_node_pool {
    name                        = "agentpool"
    vm_size                     = "Standard_D2_v2"
    node_count                  = var.node_count
    temporary_name_for_rotation = "rotation"
  }

  identity {
    type = "SystemAssigned"
  }
}


# resource "random_password" "sql_pass" {
#   length  = 16
#   special = true
# }
# resource "random_password" "sql_pass_2" {
#   length  = 16
#   special = true
# }

# resource "azurerm_mssql_server" "app-server-1" {
#   name                          = "server-${local.name}"
#   location                      = local.location
#   resource_group_name           = azurerm_resource_group.app.name
#   administrator_login           = local.name
#   administrator_login_password  = random_password.sql_pass.result
#   version                       = "12.0"
#   minimum_tls_version           = "1.2"
#   public_network_access_enabled = true
# }

# resource "azurerm_mssql_database" "app-db-1" {
#   name        = "db-${local.name}"
#   server_id   = azurerm_mssql_server.app-server-1.id
#   collation   = "SQL_Latin1_General_CP1_CI_AS"
#   max_size_gb = "1"
#   sku_name    = var.db-sku
# }

# resource "azurerm_mssql_server" "app-server-2" {
#   name                          = "server-${local.name}-2"
#   location                      = local.location
#   resource_group_name           = azurerm_resource_group.app.name
#   administrator_login           = local.name
#   administrator_login_password  = random_password.sql_pass_2.result
#   version                       = "12.0"
#   minimum_tls_version           = "1.2"
#   public_network_access_enabled = true
# }

# resource "azurerm_mssql_database" "app-db-2" {
#   name        = "db-${local.name}-2"
#   server_id   = azurerm_mssql_server.app-server-2.id
#   collation   = "SQL_Latin1_General_CP1_CI_AS"
#   max_size_gb = "1"
#   sku_name    = "Basic"
# }

resource "azurerm_container_registry" "acr" {
  name                = replace(local.name, "-", "")
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  sku                 = "Basic"
  admin_enabled       = true
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "acr_app_role_api" {
  scope                = azurerm_container_registry.acr.id
  principal_id         = azurerm_kubernetes_cluster.app.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
}

# data "azurerm_client_config" "current" {}
# resource "azurerm_key_vault" "app" {
#   name                       = "kv-${local.name}"
#   location                   = azurerm_resource_group.app.location
#   resource_group_name        = azurerm_resource_group.app.name
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   sku_name                   = "standard"
#   soft_delete_retention_days = 7

#   purge_protection_enabled = false

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     secret_permissions = ["Get", "Set", "List", "Delete"]
#   }
# }

# resource "azurerm_key_vault_secret" "sql_connection" {
#   name         = "sql-connection-string"
#   value        = "Server=tcp:${azurerm_mssql_server.app-server-1.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.app-db-1.name};User ID=${azurerm_mssql_server.app-server-1.administrator_login};Password=${random_password.sql_pass.result};Encrypt=true;Connection Timeout=30;"
#   key_vault_id = azurerm_key_vault.app.id
# }