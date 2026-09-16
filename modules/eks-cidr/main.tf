terraform {
  required_providers {
    nxip = {
      source = "uk-sw/nxip"
    }
  }
}

# Under the default AWS VPC CNI, pods get addresses directly from the VPC
# subnet CIDR (ENI-based) - there is no separate "pod CIDR" attribute on
# aws_eks_cluster the way AKS and GKE expose one. This subnet is what
# actually gets deployed as the real aws_subnet nodes and pods launch into,
# so it belongs inside the VPC: pass vpc_parent_subnet_id to nest it under
# the VPC block you already registered in nxip.
resource "nxip_subnet" "vpc_cidr" {
  environment      = var.vpc_parent_subnet_id == null ? var.environment : null
  region           = var.vpc_parent_subnet_id == null ? var.region : null
  parent_subnet_id = var.vpc_parent_subnet_id
  family           = "IPV4"
  prefix_length    = var.vpc_prefix_length
  kind             = "k8s-vpc-cidr"
  name             = "${var.cluster_name}-vpc-cidr"
}

# The Kubernetes service range is virtual: kube-proxy handles it inside the
# cluster and it is never routed in the VPC. AWS refuses a cluster whose
# serviceIpv4Cidr overlaps the VPC's own CIDR, and requires a block inside
# 10.0.0.0/8, 172.16.0.0/12 or 192.168.0.0/16, sized between /24 and /12
# (https://docs.aws.amazon.com/eks/latest/APIReference/API_KubernetesNetworkConfigRequest.html).
#
# So this is deliberately NOT nested under vpc_parent_subnet_id, however the
# VPC subnet above is placed. It is allocated top level from the pool for
# this environment and region, which is what keeps it clear of the VPC:
# nxip refuses to hand out anything overlapping a block it already knows
# about, and the VPC is one of those blocks once it is registered.
#
# The one case this cannot protect you from is a VPC that nxip has never
# seen. Register it (npx nxip-cli scan, or import it) before creating
# clusters, or AWS will reject the cluster at create time.
resource "nxip_subnet" "service_cidr" {
  environment   = var.environment
  region        = var.region
  family        = "IPV4"
  prefix_length = var.service_prefix_length
  kind          = "k8s-service-cidr"
  name          = "${var.cluster_name}-service-cidr"
}
