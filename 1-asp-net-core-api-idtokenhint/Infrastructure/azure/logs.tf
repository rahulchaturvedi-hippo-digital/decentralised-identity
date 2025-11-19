resource "azurerm_application_" "name" {
    
}

resource "azurerm_application_insights" "did-app-insights" {
  name                = "did-app-insights"
  location            = azurerm_resource_group.did-app-rg.location
  resource_group_name = azurerm_resource_group.did-app-rg.name
  application_type    = "web"
  workspace_id = ""
}