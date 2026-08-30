output "pod_cidr" {
  value       = nxip_subnet.pod_cidr.cidr
  description = "Feed into google_container_cluster.ip_allocation_policy.cluster_ipv4_cidr_block"
}

output "service_cidr" {
  value       = nxip_subnet.service_cidr.cidr
  description = "Feed into google_container_cluster.ip_allocation_policy.services_ipv4_cidr_block"
}
