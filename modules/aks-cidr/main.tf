terraform {
  required_providers {
    nxip = {
      source = "uk-sw/nxip"
    }
  }
}

# Pod and service ranges are independent top-level allocations from the pool
# for this environment and region, never nested under the VNet or under each
# other. Both must stay clear of the VNet address space: kubenet routes pod
# traffic itself and Azure refuses ranges that overlap the VNet or each
# other. Allocating them top level is what keeps them clear, because nxip
# will not hand out a block overlapping anything it already knows about, and
# the VNet is one of those blocks once it is registered.
#
# Register the VNet in nxip first (npx nxip-cli scan azure, or import it).
# A VNet nxip has never seen is the one overlap it cannot prevent.
#
# `kind` marks these as reserved for Kubernetes so they are never mistaken
# for a regular leaf subnet, and so this module can be called once per
# cluster without colliding with any other cluster in the fleet.
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
