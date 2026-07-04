# Implementation Plan: Route 53 Multi-Account DNS

## Overview

Implement a Terraform demo for classic Route 53 cross-account private DNS sharing using VPC association authorization. The implementation builds four reusable modules (`vpc`, `private-hosted-zone`, `cross-account-auth`, `test-ec2`), three account roots (`central`, `dev`, `sandbox`), and a presenter walkthrough document.

Deployment, DNS testing, and teardown are **manual steps** documented in `docs/walkthrough.md` — no `scripts/` directory, no verification harness, no CI pipelines.

## Tasks

- [x] 1. Create VPC module
  - [x] 1.1 Implement the VPC module at `terraform/modules/vpc/`
    - Create `main.tf` with `aws_vpc` (DNS support + DNS hostnames enabled), two `aws_subnet` resources across two AZs, `aws_route_table` with associations, and an `aws_security_group` allowing HTTPS (443) from VPC CIDR
    - Create three `aws_vpc_endpoint` resources for `ssm`, `ssmmessages`, `ec2messages`
    - Create `variables.tf` with inputs: `name_prefix` (string), `cidr_block` (string), `aws_region` (string)
    - Create `outputs.tf` with outputs: `vpc_id` (string), `private_subnet_ids` (list)
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 2. Create Private Hosted Zone module
  - [x] 2.1 Implement the PHZ module at `terraform/modules/private-hosted-zone/`
    - Create `main.tf` with `aws_route53_zone` (private, associated with central VPC via `vpc` block) and `aws_route53_record` using `for_each` on the `records` map
    - Create `variables.tf` with inputs: `zone_name` (string), `vpc_id` (string), `records` (map of objects with type and value)
    - Create `outputs.tf` with output: `zone_id` (string)
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 3. Create Cross-Account Auth module
  - [x] 3.1 Implement the cross-account-auth module at `terraform/modules/cross-account-auth/`
    - Create `main.tf` with `aws_route53_vpc_association_authorization` using `for_each` on the `vpc_ids` map
    - Create `variables.tf` with inputs: `zone_id` (string), `vpc_ids` (map of string), `vpc_region` (string)
    - Create `outputs.tf` with output: `authorization_ids` (map of string)
    - Ensure NO `aws_route53profiles_*` or `aws_ram_*` resources are used
    - _Requirements: 2.1, 2.2, 2.3_

- [x] 4. Create Test EC2 module
  - [x] 4.1 Implement the test-ec2 module at `terraform/modules/test-ec2/`
    - Create `main.tf` with `aws_instance` (Amazon Linux 2023 ARM64 AMI via `aws_ssm_parameter` data source, no public IP), `aws_iam_role` + `aws_iam_instance_profile` with `AmazonSSMManagedInstanceCore` policy, and `aws_security_group` (egress-only HTTPS)
    - Create `variables.tf` with inputs: `name_prefix` (string), `instance_type` (string, default `t4g.nano`), `subnet_id` (string), `vpc_id` (string)
    - Create `outputs.tf` with output: `instance_id` (string)
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 5. Checkpoint — Verify all modules
  - Review module interfaces (inputs/outputs) against the design doc. Ask the user if questions arise.

- [x] 6. Create Central account root
  - [x] 6.1 Implement the central account root at `terraform/accounts/central/`
    - Create `versions.tf` with `required_version >= 1.5.0` and AWS provider constraint
    - Create `providers.tf` with AWS provider using `var.aws_region`, `default_tags` (`Project`, `Account`, `ManagedBy`), credentials via `AWS_PROFILE`
    - Create `variables.tf` with: `aws_region` (default `ap-southeast-2`), `project_name` (default `r53demo`), `account_name` (default `central`), `instance_type` (default `t4g.nano`), `demo_domain` (default `demo.local`), `dev_vpc_id`, `sandbox_vpc_id`
    - Create `main.tf` composing modules: `vpc` (CIDR `10.0.0.0/16`, prefix `r53demo-central`), `private-hosted-zone` (zone `platform.${var.demo_domain}`, records `api` → `10.0.1.10` and `db` → `10.0.1.20`), `cross-account-auth` (VPC IDs from dev/sandbox), `test-ec2`
    - Create `outputs.tf` with: `zone_id`, `vpc_id`, `test_ec2_instance_id`
    - Create `terraform.tfvars.example` documenting all required variables
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 9, 10.1, 10.2, 10.4, 10.6_

- [x] 7. Create Dev account root
  - [x] 7.1 Implement the dev account root at `terraform/accounts/dev/`
    - Create `versions.tf` with `required_version >= 1.5.0` and AWS provider constraint
    - Create `providers.tf` with AWS provider using `var.aws_region`, `default_tags` (`Project`, `Account`, `ManagedBy`), credentials via `AWS_PROFILE`
    - Create `variables.tf` with: `aws_region` (default `ap-southeast-2`), `project_name` (default `r53demo`), `account_name` (default `dev`), `instance_type` (default `t4g.nano`), `zone_id` (default `""`), `enable_zone_association` (bool, default `true`), `enable_test_ec2` (bool, default `true`)
    - Create `main.tf` composing: `vpc` module (CIDR `10.1.0.0/16`, prefix `r53demo-dev`), conditional `aws_route53_zone_association` (gated by `enable_zone_association`), conditional `test-ec2` module (gated by `enable_test_ec2`)
    - Create `outputs.tf` with: `vpc_id`, `test_ec2_instance_id`
    - Create `terraform.tfvars.example` documenting all required variables
    - _Requirements: 3.1, 3.3, 9, 10.1, 10.5, 10.6_

- [x] 8. Create Sandbox account root
  - [x] 8.1 Implement the sandbox account root at `terraform/accounts/sandbox/`
    - Create `versions.tf` with `required_version >= 1.5.0` and AWS provider constraint
    - Create `providers.tf` with AWS provider using `var.aws_region`, `default_tags` (`Project`, `Account`, `ManagedBy`), credentials via `AWS_PROFILE`
    - Create `variables.tf` with: `aws_region` (default `ap-southeast-2`), `project_name` (default `r53demo`), `account_name` (default `sandbox`), `instance_type` (default `t4g.nano`), `zone_id` (default `""`), `enable_zone_association` (bool, default `true`), `enable_test_ec2` (bool, default `true`)
    - Create `main.tf` composing: `vpc` module (CIDR `10.2.0.0/16`, prefix `r53demo-sandbox`), conditional `aws_route53_zone_association` (gated by `enable_zone_association`), conditional `test-ec2` module (gated by `enable_test_ec2`)
    - Create `outputs.tf` with: `vpc_id`, `test_ec2_instance_id`
    - Create `terraform.tfvars.example` documenting all required variables
    - _Requirements: 3.2, 3.4, 9, 10.1, 10.5, 10.6_

- [x] 9. Checkpoint — Verify account roots
  - Confirm consistent provider config, phase-gating flags on dev/sandbox, and module composition. Ask the user if questions arise.

## Multi-region expansion (completed)

- [x] 11. Multi-region demo expansion
  - Refactored `cross-account-auth` to `authorized_vpcs` map with per-VPC `vpc_region`
  - Added `workload-stack` module and four region-suffixed workload roots
  - Replaced `central` with `network` (dual apse2 VPCs + PHZ) and `network-apse6`
  - Rewrote `docs/walkthrough.md`, `README.md`, and Kiro specs
  - Six account roots: `network`, `network-apse6`, `dev-apse2`, `dev-apse6`, `sandbox-apse2`, `sandbox-apse6`

  - Use `.kiro/specs/route53-multi-account-dns/walkthrough.md` as the source spec; output to `docs/walkthrough.md` per `.config.kiro`
  - [x] 10.1 Create `docs/walkthrough.md` — overview and prerequisites
    - Document the three-account architecture with a diagram
    - List prerequisites: three AWS accounts, AWS CLI profiles (`AWS_PROFILE`), Terraform installed
    - Document pre-flight `terraform init` + `terraform validate` before each phase
    - _Requirements: 6.5, 11.1_

  - [x] 10.2 Document Phase 1 deployment in `docs/walkthrough.md`
    - Apply dev and sandbox with `enable_zone_association=false` and `enable_test_ec2=false`
    - Include exact `terraform` commands and working directories
    - Document capturing `vpc_id` outputs from each
    - Explain why VPCs must exist before central can authorize them
    - _Requirements: 6.1, 6.4, 6.5_

  - [x] 10.3 Document Phase 2 deployment in `docs/walkthrough.md`
    - Apply central with dev/sandbox VPC IDs via `terraform.tfvars` or `-var`
    - Include exact `terraform` commands and working directory
    - Document capturing `zone_id` output
    - Explain why PHZ and authorizations must exist before associations
    - _Requirements: 6.2, 6.4, 6.5_

  - [x] 10.4 Document Phase 3 deployment in `docs/walkthrough.md`
    - Re-apply dev and sandbox with `enable_zone_association=true`, `enable_test_ec2=true`, and `zone_id` set
    - Include exact `terraform` commands and working directories
    - Explain why associations require the authorization to exist first
    - _Requirements: 6.3, 6.4, 6.5_

  - [x] 10.5 Document EC2-based DNS testing in `docs/walkthrough.md`
    - Document `aws ssm start-session --target <instance-id>` for each account
    - Document `dig +short api.platform.demo.local` (or `nslookup`) and expected answer `10.0.1.10`
    - Document repeating from central, dev, and sandbox Test EC2 instances
    - Document optional `dig +short db.platform.demo.local` → `10.0.1.20`
    - Document basic troubleshooting when `dig` returns no answer
    - _Requirements: 5.5, 5.6, 5.7_

  - [x] 10.6 Document teardown in `docs/walkthrough.md`
    - Step 1: dev/sandbox — set `enable_zone_association=false` and `enable_test_ec2=false`, apply only (removes associations and EC2, keeps VPC)
    - Step 2: destroy central account root
    - Step 3: destroy dev and sandbox VPC-only state (remaining VPC resources)
    - Include exact `terraform` commands and working directories for each step
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [x] 11. Update README
  - [x] 11.1 Update `README.md`
    - Replace Route 53 Profiles framing with classic VPC association authorization (not Profiles or RAM)
    - Link to `docs/walkthrough.md`
    - Describe repository structure (modules under `terraform/modules/`, roots under `terraform/accounts/`)
    - _Requirements: 11.2, 11.3, 11.4_

- [x] 12. Final checkpoint — Validate Terraform configuration
  - Run `terraform fmt -check` and `terraform validate` in all three account roots (`central`, `dev`, `sandbox`)
  - Confirm no `scripts/` directory and no `aws_route53profiles_*` or `aws_ram_*` resources exist
  - _Requirements: 8, 2.3, 5.7_

## Notes

- This is a Terraform (HCL) project — no application code or compiled language involved
- Property-based testing does not apply; validation is `terraform validate` plus manual EC2 DNS checks during the walkthrough
- Each task references specific requirements for traceability
- Checkpoints (tasks 5, 9, 12) validate incrementally between logical groups
- The walkthrough is the primary testing artefact — DNS resolution is verified live via SSM + `dig`
- Do **not** create: `scripts/`, verification harnesses, CI workflows, Lambda record replication, RAM shares, or Route 53 Profile resources

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "3.1", "4.1"] },
    { "id": 1, "tasks": ["5"] },
    { "id": 2, "tasks": ["6.1", "7.1", "8.1"] },
    { "id": 3, "tasks": ["9"] },
    { "id": 4, "tasks": ["10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "11.1"] },
    { "id": 5, "tasks": ["12"] }
  ]
}
```
