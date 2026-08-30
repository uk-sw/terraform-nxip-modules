variable "cluster_name" {
  type        = string
  description = "Used to name the carved subnets for identification in the nxip dashboard - not passed to Azure directly."
}

variable "environment" {
  type        = string
  default     = null
  description = "Routed to the matching nxip pool for this environment/region, same as any other nxip_subnet. Required unless parent_subnet_id is set."
}

variable "region" {
  type        = string
  default     = null
  description = "Azure region, e.g. germanywestcentral. Required unless parent_subnet_id is set."
}

variable "parent_subnet_id" {
  type        = string
  default     = null
  description = "Nest under this existing subnet instead of auto-resolving by environment/region. Only one kind-tagged landing point is allowed per environment/region/family - if one already exists (e.g. a region block), this module's own kind tags would otherwise conflict with it (HTTP 409). Pass that subnet's id here instead."
}

variable "pod_prefix_length" {
  type        = number
  default     = 20
  description = "Size of the pod CIDR block (a /20 is 4,096 addresses - AKS kubenet guidance: big enough for max pods-per-node x max node count)."
}

variable "service_prefix_length" {
  type        = number
  default     = 24
  description = "Size of the service CIDR block."
}
