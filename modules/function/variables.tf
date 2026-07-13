variable "confident_application_name" {
  type    = string
  default = "confidentai"
}

variable "confident_application_code" {
  type    = string
  default = "cai"
}

variable "confident_environment" {
  type    = string
  default = "stage"
}

variable "confident_environment_code" {
  type    = string
  default = "s"
}

variable "confident_resource_group_name" {
  type = string
}

variable "confident_azure_region" {
  type = string
}

variable "confident_tags" {
  type    = map(string)
  default = {}
}

# --- Container image (ACR) ---
variable "confident_acr_login_server" {
  description = "ACR login server, e.g. myregistry.azurecr.io."
  type        = string

  validation {
    condition     = var.confident_acr_login_server != ""
    error_message = "confident_acr_login_server is required when the code executor is enabled (confident_code_executor_enabled=true)."
  }
}

variable "confident_code_executor_function_image_name" {
  type    = string
  default = "confident-code-sandbox"
}

variable "confident_code_executor_function_image_tag" {
  type    = string
  default = "latest"
}

variable "confident_acr_admin_username" {
  type    = string
  default = ""
}

variable "confident_acr_admin_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "confident_code_executor_plan_sku" {
  type    = string
  default = "EP1"
}
