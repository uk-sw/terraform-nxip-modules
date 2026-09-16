variable "cluster_name" {
  type        = string
  description = "Used to name the carved subnets for identification in the nxip dashboard - not passed to AWS directly."
}

variable "environment" {
  type        = string
  description = "Routed to the matching nxip pool for this environment and region, same as any other nxip_subnet. Always required: the service range is allocated from it even when vpc_parent_subnet_id is set."
}

variable "region" {
  type        = string
  description = "AWS region, e.g. eu-west-1. Always required, for the same reason as environment."
}

variable "vpc_parent_subnet_id" {
  type        = string
  default     = null
  description = "Nest the real VPC subnet under this existing subnet, normally the VPC block you registered in nxip. Leave null to allocate it top level from the environment and region pool. The service range is never nested here: AWS refuses a cluster whose service CIDR overlaps the VPC."
}

variable "vpc_prefix_length" {
  type        = number
  default     = 20
  description = "Size of the VPC subnet nodes and pods actually live in - under the default AWS VPC CNI, pods are first-class VPC citizens, so there is no separate pod CIDR to allocate."
}

variable "service_prefix_length" {
  type        = number
  default     = 24
  description = "Size of the cluster's internal Kubernetes service CIDR. Virtual rather than VPC-routable, but still registered so it can never collide with anything real."

  validation {
    condition     = var.service_prefix_length >= 12 && var.service_prefix_length <= 24
    error_message = "AWS requires the EKS service CIDR to be between /24 and /12 (API_KubernetesNetworkConfigRequest)."
  }
}
