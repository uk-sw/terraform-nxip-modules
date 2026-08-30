terraform {
  required_providers {
    nxip = {
      source = "uk-sw/nxip"
    }
  }
}

# Pod and service ranges are independent top-level allocations from the
# same pool - AKS keeps them administratively separate (kubenet requires
# they don't overlap each other or the VNet), so these are siblings, not
# nested. `kind` tags them as structural/reserved-for-Kubernetes, so
# they're never mistaken for a regular leaf subnet elsewhere in the
# hierarchy, and so this module can be called once per cluster without
# colliding with any other cluster in the fleet - guaranteed by the same
# non-overlap check every other nxip_subnet already gets.
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
