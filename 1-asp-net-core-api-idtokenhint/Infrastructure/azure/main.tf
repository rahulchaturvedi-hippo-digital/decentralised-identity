terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_resource_group" "did-app-rg" {
  name     = "did-app-rg"
  location = "UK South"
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
  scope = data.azurerm_subscription.primary.id
}

data "azurerm_subscription" "primary" {}
