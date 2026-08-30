# gke-cidr

Carves guaranteed non-overlapping pod and services CIDR blocks for a
VPC-native GKE cluster from nxip, before the cluster exists. See the
[repo README](../../README.md) for the full pitch.

## Usage

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/gke-cidr"

  cluster_name = "payments-prod"
  environment  = "production"
  region       = "europe-west3"
}

resource "google_container_cluster" "payments" {
  name     = "payments-prod"
  location = "europe-west3"

  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.vpc.id
  subnetwork      = google_compute_subnetwork.nodes.id

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = module.cluster_cidrs.pod_cidr
    services_ipv4_cidr_block = module.cluster_cidrs.service_cidr
  }

  initial_node_count = 3
}
```

Run this once per cluster, the pod/service ranges are checked against
every other allocation already registered in your organization, cluster
CIDR conflicts across a fleet aren't possible by construction.

**If your environment/region already has a structural landing point**
(e.g. a `kind`-tagged region block), pass `parent_subnet_id` instead of
`environment`/`region`. Only one kind-tagged landing point is allowed per
environment/region/family - found this from real testing against
[nxip-terraform-lab](https://github.com/uk-sw/nxip-terraform-lab)'s
existing region block, this module's own `environment`/`region` path
fails with a `409` in that case:

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/gke-cidr"

  cluster_name     = "payments-prod"
  parent_subnet_id = nxip_subnet.production_us_east_region.id
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `cluster_name` | Used to name the carved subnets for identification in nxip - not passed to GCP. | (required) |
| `environment` | Routed to the matching nxip pool, same as any other `nxip_subnet`. | Required unless `parent_subnet_id` is set. |
| `region` | GCP region. | Required unless `parent_subnet_id` is set. |
| `parent_subnet_id` | Nest under this existing subnet instead - see above. | `null` |
| `pod_prefix_length` | Size of the cluster (pod) CIDR block. | `20` (4,096 addresses) |
| `service_prefix_length` | Size of the services CIDR block. | `24` (256 addresses) |

## Outputs

| Name | Description |
|---|---|
| `pod_cidr` | Feed into `ip_allocation_policy.cluster_ipv4_cidr_block` |
| `service_cidr` | Feed into `ip_allocation_policy.services_ipv4_cidr_block` |
