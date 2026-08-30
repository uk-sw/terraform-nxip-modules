variable "cluster_name" {
  type        = string
  description = "Used to name the carved subnets for identification in the nxip dashboard - not passed to GCP directly."
}

variable "environment" {
  type        = string
  description = "Routed to the matching nxip pool for this environment/region, same as any other nxip_subnet."
}

variable "region" {
  type        = string
  description = "GCP region, e.g. europe-west3."
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
