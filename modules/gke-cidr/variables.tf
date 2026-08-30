variable "cluster_name" {
  type        = string
  description = "Used to name the carved subnets for identification in the nxip dashboard - not passed to GCP directly."
}

variable "environment" {
  type        = string
  default     = null
  description = "Routed to the matching nxip pool for this environment/region, same as any other nxip_subnet. Required unless parent_subnet_id is set."
}

variable "region" {
  type        = string
  default     = null
  description = "GCP region, e.g. europe-west3. Required unless parent_subnet_id is set."
}

variable "parent_subnet_id" {
  type        = string
  default     = null
  description = "Nest under this existing subnet instead of auto-resolving by environment/region. Only one kind-tagged landing point is allowed per environment/region/family - if one already exists (e.g. a region block), this module's own kind tags would otherwise conflict with it (HTTP 409). Pass that subnet's id here instead."
}

variable "pod_prefix_length" {
  type        = number
  default     = 20
  description = "Size of the cluster (pod) CIDR block."
}

variable "service_prefix_length" {
  type        = number
  default     = 24
  description = "Size of the services CIDR block."
}
