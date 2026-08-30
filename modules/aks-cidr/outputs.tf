output "pod_cidr" {
  value       = nxip_subnet.pod_cidr.cidr
  description = "Feed directly into azurerm_kubernetes_cluster.network_profile.pod_cidr"
}

output "service_cidr" {
  value       = nxip_subnet.service_cidr.cidr
  description = "Feed directly into azurerm_kubernetes_cluster.network_profile.service_cidr"
}
