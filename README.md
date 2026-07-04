# Route 53 Multi-Account Multi-Region DNS Demo

Terraform demo for cross-account and multi-region private DNS sharing in AWS using the **classic VPC association authorization** pattern.

Does **not** use Route 53 Profiles, AWS RAM, or Transit Gateway.

## Architecture

One PHZ (`platform.demo.local`) in the **network** account, shared across **six stacks** in **two regions** (`ap-southeast-2`, `ap-southeast-6`):

| Stack | Account | Region | Scenario |
|-------|---------|--------|----------|
| `network` | network | ap-southeast-2 | PHZ owner + same-account second VPC |
| `network-apse6` | network | ap-southeast-6 | Same-account cross-region |
| `dev-apse2` | dev | ap-southeast-2 | Cross-account same-region |
| `dev-apse6` | dev | ap-southeast-6 | Cross-account cross-region |
| `sandbox-apse2` | sandbox | ap-southeast-2 | Cross-account same-region |
| `sandbox-apse6` | sandbox | ap-southeast-6 | Cross-account cross-region |

Full topology, DNS resolution flow, and phased dependencies: [docs/architecture.md](docs/architecture.md).

Phased manual deployment with boolean feature flags. DNS verification via SSM + `dig` from seven Test EC2 instances. AWS provider pinned to **6.53.0** per stack (supports `ap-southeast-6`).

## Repository structure

```text
terraform/
├── modules/
│   ├── vpc/
│   ├── private-hosted-zone/
│   ├── cross-account-auth/    # per-VPC vpc_region
│   ├── workload-stack/
│   └── test-ec2/
└── accounts/
    ├── network/
    ├── network-apse6/
    ├── dev-apse2/
    ├── dev-apse6/
    ├── sandbox-apse2/
    └── sandbox-apse6/
docs/
├── architecture.md
└── walkthrough.md
```

## Getting started

Configure AWS CLI profiles (`r53demo-network`, `r53demo-dev`, `r53demo-sandbox`).

- [docs/architecture.md](docs/architecture.md) — topology, **VPC association requirements** (security, IAM, best practices), module map
- [docs/walkthrough.md](docs/walkthrough.md) — phased deploy, DNS tests, teardown

## License

See [LICENSE](LICENSE).
