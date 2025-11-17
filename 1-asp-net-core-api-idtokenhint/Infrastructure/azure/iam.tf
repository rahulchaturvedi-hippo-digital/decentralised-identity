# Assign Contributor role to the Service Principal for this Resource Group
resource "azurerm_role_assignment" "did_app_contributor_ra" {
  principal_id       = azuread_service_principal.did_tf_sp.id
  scope                = data.azurerm_subscription.primary.id
  role_definition_id = data.azurerm_role_definition.contributor.id 
}

resource "azuread_application" "did_app_tf" {
  display_name = "did-app-tf"
}

resource "azuread_service_principal" "did_tf_sp" {
  client_id = azuread_application.did_app_tf.client_id
}

resource "azuread_application_password" "terraform_sp_secret" {
  application_id = azuread_application.did_app_tf.id
  display_name          = "did-tf-sp-secret"
  end_date_relative     = "4320h"
}