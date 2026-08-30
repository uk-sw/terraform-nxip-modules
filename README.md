# terraform-nxip-modules

Terraform modules wiring [nxip](https://nxip.dev)-managed CIDR allocation
into common infrastructure patterns. First up: multi-cluster Kubernetes
CIDR authority, the thing you call *before* a new cluster exists, not
after.

## The problem

Every existing Kubernetes IPAM mechanism, [Whereabouts](https://github.com/k8snetworkplumbingwg/whereabouts),
Cilium's cluster-pool IPAM, NVIDIA's IPAM plugin, coordinates pod/service
CIDR allocation *within* one cluster. None of them coordinate *across* a
fleet of clusters, and conflicting CIDRs across clusters is a real,
[documented failure mode](https://oneuptime.com/blog/post/2026-03-13-cilium-ipam-conflicting-node-cidrs/view):
packets destined for a pod on one node get misrouted to another node with
an overlapping range. No SaaS offering centrally-coordinated, cross-cluster
IPAM exists today, this is genuinely unowned white space, not a repeat of
a problem someone else already solved.

## The pitch

Each module below is a thin wrapper around `nxip_subnet`, nxip's existing
guaranteed-non-overlapping CIDR primitive, already used for VPC subnets
today. Call the matching module once per cluster, plug its outputs into
your cluster resource's own CIDR inputs, and every cluster in the fleet is
guaranteed non-overlapping against every other one, and against every
other piece of address space your organization has ever registered in
nxip, VPCs, on-prem sites, other clusters, all of it.

This puts nxip in the *provisioning* path for Kubernetes networking, not
just the *observation* path, a materially stronger position than watching
after the fact and reporting drift.

## Modules

| Module | What it wires up |
|---|---|
| [`aks-cidr`](modules/aks-cidr) | `network_profile.pod_cidr` / `service_cidr` on `azurerm_kubernetes_cluster` |
| [`gke-cidr`](modules/gke-cidr) | `ip_allocation_policy.cluster_ipv4_cidr_block` / `services_ipv4_cidr_block` on `google_container_cluster` |
| [`eks-cidr`](modules/eks-cidr) | The real VPC subnet nodes/pods deploy into, plus `kubernetes_network_config.service_ipv4_cidr` on `aws_eks_cluster` |

Each module's own README has a full, real usage example wired to that
cloud's actual cluster resource.

## What's next, and what isn't here yet

This is the cheap version: pure packaging over CIDR allocation that
already works, no new nxip backend code. The harder, more defensible
version, active discovery of *existing* clusters' already-assigned CIDRs
(retroactive import, the same pattern as `terraform import` for existing
subnets), and eventually a validating admission webhook that blocks a
cluster from being misconfigured with a colliding CIDR even outside
Terraform entirely, is real new engineering, tracked separately as bet #7
in [nxip's roadmap](https://github.com/uk-sw/net-saas/blob/main/docs/roadmap.md).

## Requirements

- A [nxip](https://nx-ip.com/signup) account and API key (`NXIP_API_KEY`
  env var, or set `api_key` on the provider block).
- Terraform `~> 1.x`, the [`uk-sw/nxip`](https://registry.terraform.io/providers/uk-sw/nxip/latest)
  provider (pinned per-module, add a `version` constraint for your own
  usage).
- The relevant cloud provider (`aws`, `azurerm`, or `google`) configured
  as normal, these modules only carve the CIDR, they don't touch cloud
  credentials or provision anything cloud-side themselves.
