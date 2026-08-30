# aks-cidr

Carves guaranteed non-overlapping pod and service CIDR blocks for an AKS
cluster from nxip, before the cluster exists.

Every existing Kubernetes IPAM mechanism (Whereabouts, Cilium's cluster-pool
IPAM, NVIDIA's IPAM plugin) coordinates allocation *within* one cluster.
None of them coordinate *across* a fleet of clusters - which is exactly
the failure mode that produces conflicting CIDRs across clusters, packets
destined for a pod on one node getting misrouted to another node with an
overlapping range. Since every `nxip_subnet` this module carves is checked
against every other allocation in your organization, calling it once per
cluster is enough to guarantee no two clusters in the fleet ever collide,
without maintaining a spreadsheet of "which CIDR ranges are already taken."

## Usage

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/aks-cidr"

  cluster_name = "payments-prod"
  environment  = "production"
  region       = "germanywestcentral"
}

resource "azurerm_kubernetes_cluster" "payments" {
  name                = "payments-prod"
  location            = "germanywestcentral"
  resource_group_name = azurerm_resource_group.payments.name
  dns_prefix          = "payments-prod"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  network_profile {
    network_plugin = "kubenet"
    pod_cidr       = module.cluster_cidrs.pod_cidr
    service_cidr   = module.cluster_cidrs.service_cidr
    dns_service_ip = cidrhost(module.cluster_cidrs.service_cidr, 10)
  }

  identity {
    type = "SystemAssigned"
  }
}
```

Run this a second time for a second cluster (`payments-staging`,
`checkout-prod`, whatever's next) and the pod/service ranges it gets are
guaranteed distinct from every cluster that came before, cluster-by-cluster
math you'd otherwise have to track by hand.

**If your environment/region already has a structural landing point**
(e.g. a `kind`-tagged region block), pass `parent_subnet_id` instead of
`environment`/`region`. Only one kind-tagged landing point is allowed per
environment/region/family - found this from real testing against
[nxip-terraform-lab](https://github.com/uk-sw/nxip-terraform-lab)'s
existing region block, this module's own `environment`/`region` path
fails with a `409` in that case:

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/aks-cidr"

  cluster_name     = "payments-prod"
  parent_subnet_id = nxip_subnet.production_us_east_region.id
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `cluster_name` | Used to name the carved subnets for identification in nxip - not passed to Azure. | (required) |
| `environment` | Routed to the matching nxip pool, same as any other `nxip_subnet`. | Required unless `parent_subnet_id` is set. |
| `region` | Azure region. | Required unless `parent_subnet_id` is set. |
| `parent_subnet_id` | Nest under this existing subnet instead - see above. | `null` |
| `pod_prefix_length` | Size of the pod CIDR block. | `20` (4,096 addresses) |
| `service_prefix_length` | Size of the service CIDR block. | `24` (256 addresses) |

## Outputs

| Name | Description |
|---|---|
| `pod_cidr` | Feed into `network_profile.pod_cidr` |
| `service_cidr` | Feed into `network_profile.service_cidr` |
