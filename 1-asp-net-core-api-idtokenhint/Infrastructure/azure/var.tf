variable "tenant_id" {
  description = "The Tenant ID for the Azure AD"
  type        = string
}
variable "client_id" {
  description = "The Client ID for the Service Principal"
  type        = string
}
variable "client_secret" {
  description = "The Client Secret for the Service Principal"
  type        = string
  sensitive   = true
}
variable "did_auth" {
  description = "The DID Authority URL"
  type        = string
}
variable "cred_manifest" {
    description = "The Credential Manifest URL"
    type        = string
}