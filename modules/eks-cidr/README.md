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

**Where each range is placed, and why it matters.** The VPC subnet is a
real, routable block, so it belongs inside your VPC: pass
`vpc_parent_subnet_id` to nest it under the VPC block you registered in
nxip. The service range is virtual and must NOT overlap the VPC. AWS
refuses a cluster whose `serviceIpv4Cidr` overlaps the VPC's own CIDR, and
requires a block inside `10.0.0.0/8`, `172.16.0.0/12` or `192.168.0.0/16`
sized between `/24` and `/12`
([AWS API reference](https://docs.aws.amazon.com/eks/latest/APIReference/API_KubernetesNetworkConfigRequest.html)).
So the service range is always allocated top level from the pool for this
environment and region, never under `vpc_parent_subnet_id`.

That placement is what keeps it clear of the VPC: nxip refuses to hand out
anything overlapping a block it already knows about. **Register the VPC in
nxip first** (`npx nxip-cli scan aws`, or import it). A VPC nxip has never
seen is the one overlap it cannot prevent, and AWS will reject the cluster
at create time.

```hcl
module "cluster_cidrs" {
  source = "github.com/uk-sw/terraform-nxip-modules//modules/eks-cidr"

  cluster_name         = "payments-prod"
  environment          = "production"
  region               = "us-east-1"
  vpc_parent_subnet_id = nxip_subnet.payments_vpc.id
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `cluster_name` | Used to name the carved subnets for identification in nxip - not passed to AWS. | (required) |
| `environment` | Routed to the matching nxip pool, same as any other `nxip_subnet`. | (required) |
| `region` | AWS region. | (required) |
| `vpc_parent_subnet_id` | Nest the real VPC subnet under this block, normally your VPC. The service range is never nested here. | `null` |
| `vpc_prefix_length` | Size of the real VPC subnet nodes/pods deploy into. | `20` (4,096 addresses) |
| `service_prefix_length` | Size of the virtual Kubernetes service CIDR. | `24` (256 addresses) |

## Outputs

| Name | Description |
|---|---|
| `vpc_cidr` | The real VPC subnet CIDR - use as `aws_subnet.cidr_block` |
| `service_cidr` | Feed into `kubernetes_network_config.service_ipv4_cidr` |
