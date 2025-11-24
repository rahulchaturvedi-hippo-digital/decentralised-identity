variable "did_app_kv_rg" {
  description = "The Resource Group name for the DID App Key Vault resource group"
  default     = "did-app-kv-rg"
}

variable "did_app_kv" {
  description = "Name of the DID app key vault"
  default     = "did-app-kv"
}

variable "did_app_rg" {
  description = "Did app resource group"
  default     = "did-app-rg"
}

variable "did_app_rg_location" {
  description = "Did app resource group location"
  default     = "UK South"
}