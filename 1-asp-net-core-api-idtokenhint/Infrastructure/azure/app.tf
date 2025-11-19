resource "azurerm_service_plan" "did-app-plan" {
  name                = "did-app-service-plan"
  location            = azurerm_resource_group.did-app-rg.location
  resource_group_name = azurerm_resource_group.did-app-rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "did-app-service" {
  name                = "did-app-service"
  resource_group_name = azurerm_resource_group.did-app-rg.name
  location            = azurerm_service_plan.did-app-plan.location
  service_plan_id     = azurerm_service_plan.did-app-plan.id
  site_config {
    always_on = false
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.appi.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appi.connection_string
    "APPLICATIONINSIGHTS_ENABLE_LOGGING"    = "true"
  }
}

data "azurerm_key_vault" "did_key_vault" {
  name                = "did-app-kv"
  resource_group_name = data.azurerm_resource_group.did_app_kv_rg.name
}

data "azurerm_key_vault_secret" "tenant_id" {
  name         = "TenantID"
  key_vault_id = data.azurerm_key_vault.did_key_vault.id
}

data "azurerm_key_vault_secret" "client_id" {
  name         = "ClientID"
  key_vault_id = data.azurerm_key_vault.did_key_vault.id
}

data "azurerm_key_vault_secret" "client_secret" {
  name         = "ClientSecret"
  key_vault_id = data.azurerm_key_vault.did_key_vault.id
}

data "azurerm_key_vault_secret" "did_auth" {
  name         = "DidAuth"
  key_vault_id = data.azurerm_key_vault.did_key_vault.id
}

data "azurerm_key_vault_secret" "cred_manifest" {
  name         = "CredManifest"
  key_vault_id = data.azurerm_key_vault.did_key_vault.id
}

resource "null_resource" "did-app-deploy" {
  provisioner "local-exec" {
    command = "cd ../.. && python3 configure_settings.py --tenantID=${data.azurerm_key_vault_secret.tenant_id.value} --clientID=${data.azurerm_key_vault_secret.client_id.value} --clientSecret=${data.azurerm_key_vault_secret.client_secret.value} --didAuth=${data.azurerm_key_vault_secret.did_auth.value} --credManifest=${data.azurerm_key_vault_secret.cred_manifest.value} && dotnet publish ./AspNetCoreVerifiableCredentials.csproj --configuration Release --output ./deploy && cd deploy && zip -r ../myapp.zip * && cd .. && az webapp deploy --resource-group ${azurerm_linux_web_app.did-app-service.resource_group_name} --name ${azurerm_linux_web_app.did-app-service.name} --src-path ./myapp.zip --type zip"
  }
  depends_on = [azurerm_linux_web_app.did-app-service]
}

output "did_app_service_url" {
  value = "https://${azurerm_linux_web_app.did-app-service.default_hostname}/"
}