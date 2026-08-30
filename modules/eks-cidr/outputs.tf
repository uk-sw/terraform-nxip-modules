output "vpc_cidr" {
  value       = nxip_subnet.vpc_cidr.cidr
  description = "The real VPC subnet CIDR to deploy nodes/pods into (aws_subnet.cidr_block)"
}

output "service_cidr" {
  value       = nxip_subnet.service_cidr.cidr
  description = "Feed into aws_eks_cluster.kubernetes_network_config.service_ipv4_cidr"
}
