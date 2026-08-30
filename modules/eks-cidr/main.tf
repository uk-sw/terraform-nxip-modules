terraform {
  required_providers {
    nxip = {
      source = "uk-sw/nxip"
    }
  }
}

# Under the default AWS VPC CNI, pods get addresses directly from the VPC
# subnet CIDR (ENI-based) - there's no separate "pod CIDR" attribute on
# aws_eks_cluster the way AKS/GKE expose one. This subnet is what actually
# gets deployed as the real aws_subnet nodes and pods launch into.
resource "nxip_subnet" "vpc_cidr" {
  environment   = var.environment
  region        = var.region
  family        = "IPV4"
  prefix_length = var.vpc_prefix_length
  kind          = "k8s-vpc-cidr"
  name          = "${var.cluster_name}-vpc-cidr"
}

# The Kubernetes service range is virtual, not a real VPC-routable block -
# kube-proxy handles it internally, kubernetes_network_config.service_ipv4_cidr
# just needs a value guaranteed not to collide with anything else, real or
# virtual, in the fleet. Registering it in nxip gets that guarantee for free.
resource "nxip_subnet" "service_cidr" {
  environment   = var.environment
  region        = var.region
  family        = "IPV4"
  prefix_length = var.service_prefix_length
  kind          = "k8s-service-cidr"
  name          = "${var.cluster_name}-service-cidr"
}
