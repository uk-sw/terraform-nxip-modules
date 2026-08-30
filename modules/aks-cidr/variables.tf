variable "cluster_name" {
  type        = string
  description = "Used to name the carved subnets for identification in the nxip dashboard - not passed to Azure directly."
}

variable "environment" {
  type        = string
  description = "Routed to the matching nxip pool for this environment/region, same as any other nxip_subnet."
}

variable "region" {
  type        = string
  description = "Azure region, e.g. germanywestcentral."
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
