terraform {
  required_providers {
    nxip = {
      source = "uk-sw/nxip"
    }
  }
}

# GKE's ip_allocation_policy takes an explicit pod (cluster) CIDR and
# services CIDR when it is not referencing pre-created VPC secondary ranges.
# Both are secondary ranges, so neither may overlap the subnet's primary
# range or each other. They are allocated top level from the pool for this
# environment and region, never nested under the VPC block, which is what
# keeps them clear of it: nxip will not hand out a block overlapping
# anything it already knows about.
#
# Register the VPC in nxip first (npx nxip-cli scan, or import it). A
# network nxip has never seen is the one overlap it cannot prevent.
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
