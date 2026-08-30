# eks-cidr

Carves guaranteed non-overlapping VPC and service CIDR blocks for an EKS
cluster from nxip, before the cluster exists. See the
[repo README](../../README.md) for the full pitch.

**One honest nuance specific to EKS**: under the default AWS VPC CNI,
pods are first-class VPC citizens, there's no separate "pod CIDR" the way
AKS and GKE expose one. What this module actually carves is the real VPC
subnet nodes and pods launch into, plus the cluster's internal (virtual,
non-VPC-routable) Kubernetes service range.

## Usage

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/eks-cidr"

  cluster_name = "payments-prod"
  environment  = "production"
  region       = "eu-west-1"
}

resource "aws_subnet" "eks_nodes" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.cluster_cidrs.vpc_cidr
  availability_zone = "eu-west-1a"
}

resource "aws_eks_cluster" "payments" {
  name     = "payments-prod"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks_nodes.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = module.cluster_cidrs.service_cidr
  }
}
```

Run this once per cluster, both ranges are checked against every other
allocation already registered in your organization, so a second cluster's
VPC and service ranges are guaranteed distinct from the first without
tracking it by hand.

**If your environment/region already has a structural landing point**
(e.g. a `kind`-tagged region block), pass `parent_subnet_id` instead of
`environment`/`region`. Only one kind-tagged landing point is allowed per
environment/region/family - found this for real testing against
[nxip-terraform-lab](https://github.com/uk-sw/nxip-terraform-lab)'s
existing region block, this module's own `environment`/`region` path
fails with a `409` in that case:

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/eks-cidr"

  cluster_name     = "payments-prod"
  parent_subnet_id = nxip_subnet.production_us_east_region.id
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `cluster_name` | Used to name the carved subnets for identification in nxip - not passed to AWS. | (required) |
| `environment` | Routed to the matching nxip pool, same as any other `nxip_subnet`. | Required unless `parent_subnet_id` is set. |
| `region` | AWS region. | Required unless `parent_subnet_id` is set. |
| `parent_subnet_id` | Nest under this existing subnet instead - see above. | `null` |
| `vpc_prefix_length` | Size of the real VPC subnet nodes/pods deploy into. | `20` (4,096 addresses) |
| `service_prefix_length` | Size of the virtual Kubernetes service CIDR. | `24` (256 addresses) |

## Outputs

| Name | Description |
|---|---|
| `vpc_cidr` | The real VPC subnet CIDR - use as `aws_subnet.cidr_block` |
| `service_cidr` | Feed into `kubernetes_network_config.service_ipv4_cidr` |
