# --- Naming ---
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

variable "confident_region_prefix" {
  type    = string
  default = "azew"
}

variable "confident_tags" {
  type    = map(string)
  default = {}
}

# --- Location / RG (existing) ---
variable "confident_resource_group_name" {
  type = string
}

variable "confident_azure_region" {
  type = string
}

# --- Networking (existing VNet/subnet) ---
variable "confident_aks_subnet_id" {
  description = "Existing subnet the AKS nodes attach to."
  type        = string
}

# --- Cluster ---
variable "confident_kubernetes_version" {
  type    = string
  default = "1.34.2"
}

variable "confident_public_aks" {
  type    = bool
  default = false
}

variable "confident_aks_admin_group_object_ids" {
  type    = list(string)
  default = []
}

variable "confident_node_vm_size" {
  type    = string
  default = "Standard_D8s_v5"
}

variable "confident_node_group_min_size" {
  type    = number
  default = 2
}

variable "confident_node_group_max_size" {
  type    = number
  default = 8
}

variable "confident_node_group_desired_size" {
  type    = number
  default = 4
}
