variable "cluster_name" {
  type        = string
  description = "Used to name the carved subnets for identification in the nxip dashboard - not passed to AWS directly."
}

variable "environment" {
  type        = string
  description = "Routed to the matching nxip pool for this environment/region, same as any other nxip_subnet."
}

variable "region" {
  type        = string
  description = "AWS region, e.g. eu-west-1."
}

variable "vpc_prefix_length" {
  type        = number
  default     = 20
  description = "Size of the VPC subnet nodes and pods actually live in - under the default AWS VPC CNI, pods are first-class VPC citizens, there's no separate pod CIDR to allocate."
}

variable "service_prefix_length" {
  type        = number
  default     = 24
  description = "Size of the cluster's internal Kubernetes service CIDR - virtual, not a real VPC-routable range, but still worth registering to guarantee it never collides with anything real."
}
