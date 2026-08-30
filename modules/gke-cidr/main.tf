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
resource "nxip_subnet" "pod_cidr" {
  environment   = var.environment
  region        = var.region
  family        = "IPV4"
  prefix_length = var.pod_prefix_length
  kind          = "k8s-pod-cidr"
  name          = "${var.cluster_name}-pod-cidr"
}

resource "nxip_subnet" "service_cidr" {
  environment   = var.environment
  region        = var.region
  family        = "IPV4"
  prefix_length = var.service_prefix_length
  kind          = "k8s-service-cidr"
  name          = "${var.cluster_name}-service-cidr"
}
