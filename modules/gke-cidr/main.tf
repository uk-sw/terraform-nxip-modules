terraform {
  required_providers {
    nxip = {
      source = "uk-sw/nxip"
    }
  }
}

# GKE's ip_allocation_policy takes an explicit pod (cluster) CIDR and
# services CIDR when not referencing pre-created VPC secondary ranges -
# the same two independent, non-overlapping blocks every other cloud in
# this repo needs, just under GCP's own naming for them.
#
# environment/region and parent_subnet_id are mutually exclusive, same as
# nxip_subnet itself - when parent_subnet_id is set, environment/region are
# left null so this nests under that subnet instead of auto-resolving a new
# top-level landing point (which would conflict with one that already
# exists for this environment/region/family - see variables.tf).
resource "nxip_subnet" "pod_cidr" {
  environment      = var.parent_subnet_id == null ? var.environment : null
  region           = var.parent_subnet_id == null ? var.region : null
  parent_subnet_id = var.parent_subnet_id
  family           = "IPV4"
  prefix_length    = var.pod_prefix_length
  kind             = "k8s-pod-cidr"
  name             = "${var.cluster_name}-pod-cidr"
}

resource "nxip_subnet" "service_cidr" {
  environment      = var.parent_subnet_id == null ? var.environment : null
  region           = var.parent_subnet_id == null ? var.region : null
  parent_subnet_id = var.parent_subnet_id
  family           = "IPV4"
  prefix_length    = var.service_prefix_length
  kind             = "k8s-service-cidr"
  name             = "${var.cluster_name}-service-cidr"
}
