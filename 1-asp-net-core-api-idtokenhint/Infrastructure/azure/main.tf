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


  backend "azurerm" {
    resource_group_name  = "tf-state-holder-rg"
    storage_account_name = "didtfstateholder"
    container_name       = "tf-state"
    key                  = "terraform.tfstate"
  }

  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
}

resource "azurerm_resource_group" "did_app_rg" {
  name     = var.did_app_rg
  location = var.did_app_rg_location
}

data "azurerm_resource_group" "did_app_kv_rg" {
  name = var.did_app_kv_rg
}

data "azurerm_role_definition" "contributor" {
  name  = "Contributor"
  scope = data.azurerm_subscription.primary.id
}

data "azurerm_subscription" "primary" {}
