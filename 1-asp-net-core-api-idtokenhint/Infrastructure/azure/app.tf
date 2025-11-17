resource "azurerm_app_service_plan" "did-app-plan" {
  name                = "did-app-service-plan"
  location            = azurerm_resource_group.did-app-rg.location
  resource_group_name = azurerm_resource_group.did-app-rg.name
  kind                = "Linux"

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "did-app-service" {
  name                = "did-app-service"
  location            = azurerm_resource_group.did-app-rg.location
  resource_group_name = azurerm_resource_group.did-app-rg.name
  app_service_plan_id = azurerm_app_service_plan.did-app-plan.id

  site_config {
    dotnet_framework_version = "v8.0"
    scm_type                 = "None"
  }
}

resource "null_resource" "did-app-deploy" {
  provisioner "local-exec" {
    command = <<EOT
      cd  ../../
      python3 configure_settings.py --tenant-id=${var.tenant_id} --client-id=${var.client_id} --client-secret=${var.client_secret} --did-auth="${var.did_auth}" --cred-manifest="${var.cred_manifest}"
      dotnet publish ../Application/1-asp-net-core-api-idtokenhint -c Release -o ../Application/1-asp-net-core-api-idtokenhint/bin/Release/net8.0/publish
      az webapp deploy --resource-group ${azurerm_resource_group.did-app-rg.name} --name ${azurerm_app_service.did-app-service.name} --src-path ../Application/1-asp-net-core-api-idtokenhint/bin/Release/net8.0/publish
    EOT
  }

  depends_on = [azurerm_app_service.did-app-service]
}
