resource "azurerm_log_analytics_workspace" "did_log_workspace" {
  name                = "did-log-workspace"
  location            = azurerm_resource_group.did_app_rg.location
  resource_group_name = azurerm_resource_group.did_app_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "did_app_insight" {
  name                = "did-app-insight"
  location            = azurerm_resource_group.did_app_rg.location
  resource_group_name = azurerm_resource_group.did_app_rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.did_log_workspace.id
}

# Storage account
resource "azurerm_storage_account" "did_storage_acct" {
  name                     = "didstorageacct"
  resource_group_name      = azurerm_resource_group.did_app_rg.name
  location                 = azurerm_resource_group.did_app_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Blob container for App Service logs
resource "azurerm_storage_container" "did_log_storage" {
  name                  = "didlogstorage"
  storage_account_name  = azurerm_storage_account.did_storage_acct.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.did_storage_acct]
}

# SAS for App Service to write logs
data "azurerm_storage_account_sas" "logs_sas" {
  connection_string = azurerm_storage_account.did_storage_acct.primary_connection_string
  start             = timestamp()
  expiry            = "2030-01-01T00:00:00Z"
  signed_version    = "2021-06-08"

  services {
    blob  = true
    file  = true
    queue = true
    table = true
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = true
  }

  depends_on = [azurerm_storage_account.did_storage_acct]
}

locals {
  log_sas_url = "${azurerm_storage_account.did_storage_acct.primary_blob_endpoint}${azurerm_storage_container.did_log_storage.name}?${data.azurerm_storage_account_sas.logs_sas.sas}"
}

output "endpoint" {
  value = azurerm_storage_account.did_storage_acct.primary_blob_endpoint
}
output "strg" {
  value = azurerm_storage_container.did_log_storage.name
}

resource "azurerm_monitor_diagnostic_setting" "export-did-app-logs" {
  name               = "export-did-app-logs"
  target_resource_id = azurerm_linux_web_app.did_app_service.id
  storage_account_id = azurerm_storage_account.did_storage_acct.id

  enabled_log {
    category = "AppServiceAppLogs"
  }
}



