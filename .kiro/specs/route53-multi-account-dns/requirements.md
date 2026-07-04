# Requirements Document

## Introduction

This feature implements a Terraform demo for **classic Route 53 cross-account and multi-region private DNS sharing** using VPC association authorization:

1. A **network account** owns one private hosted zone (PHZ) and its records.
2. The network account **authorizes** cross-account workload VPCs (per VPC ID and region).
3. Each **workload stack** **associates** its VPC with the shared zone.
4. The network account also demonstrates **same-account** associations (second VPC same region, VPC in ap-southeast-6).

**Regions:** `ap-southeast-2` and `ap-southeast-6`. **Stacks:** six Terraform roots (`network`, `network-apse6`, `dev-apse2`, `dev-apse6`, `sandbox-apse2`, `sandbox-apse6`).

**Testing is intentionally simple:** one small EC2 instance per account, connect via SSM Session Manager, run `dig` or `nslookup` from the shell. No test harness, no verification scripts, no extra tooling.

Deploy and teardown are **manual presenter steps** in the walkthrough.

This demo intentionally does **not** use AWS RAM, Route 53 Profiles, record replication, Transit Gateway, Route 53 Resolver endpoints, DNS Firewall, public hosted zones, or orchestration/verification scripts.

## Glossary

- **Network_Account**: AWS account that owns the shared PHZ, DNS records, and VPC association authorizations (formerly central)
- **Central_Account**: Alias for Network_Account in legacy references
- **Dev_Account**: Workload AWS account that associates its VPC with the central PHZ
- **Sandbox_Account**: Second workload AWS account, same pattern as Dev_Account with different naming
- **PHZ**: Private Hosted Zone — resolves DNS only from associated VPCs
- **VPC_Association_Authorization**: Route 53 action in the zone-owning account permitting another account's VPC to associate
- **VPC_Association**: Action in the VPC-owning account linking that VPC to an authorized PHZ
- **Demo_Domain**: Base domain for the demo (default: `demo.local`)
- **Platform_Zone**: Shared PHZ in Network_Account (`platform.{Demo_Domain}`)
- **Test_EC2**: One minimal EC2 per stack (seven total), used to run DNS lookups from inside each VPC
- **Walkthrough**: Presenter guide (`docs/walkthrough.md`) with phased apply, EC2-based DNS checks, and teardown steps

## Requirements

### Requirement 1: Central Private Hosted Zone

**User Story:** As a platform engineer, I want one private hosted zone in the central account, so shared DNS has a single authoritative source.

#### Acceptance Criteria

1. WHEN Terraform is applied in Central_Account, THE PHZ_Module SHALL create a private hosted zone named `platform.{Demo_Domain}`
2. WHEN the Platform_Zone is created, THE PHZ_Module SHALL create an A record for `api.platform.{Demo_Domain}` pointing to `10.0.1.10`
3. WHEN the Platform_Zone is created, THE PHZ_Module SHALL create an A record for `db.platform.{Demo_Domain}` pointing to `10.0.1.20`
4. THE PHZ_Module SHALL associate the Central_Account VPC with the Platform_Zone

### Requirement 2: Cross-Account VPC Association Authorization

**User Story:** As a platform engineer, I want the central account to authorize dev and sandbox VPCs, so those accounts can use the shared zone.

#### Acceptance Criteria

1. WHEN dev and sandbox VPC IDs are provided as inputs, THE Cross_Account_Auth_Module SHALL create a VPC_Association_Authorization for each VPC in Central_Account
2. THE Cross_Account_Auth_Module SHALL use only the native Route 53 `CreateVPCAssociationAuthorization` / `AssociateVPCWithHostedZone` pattern
3. THE Cross_Account_Auth_Module SHALL NOT use `aws_route53profiles_*` or `aws_ram_*` resources

### Requirement 3: Workload Account VPC Association

**User Story:** As a workload account owner, I want my VPC associated with the central PHZ, so my workloads resolve shared platform DNS without local record copies.

#### Acceptance Criteria

1. WHEN the VPC_Association_Authorization exists, THE Dev_Account root SHALL associate the dev VPC with the Platform_Zone
2. WHEN the VPC_Association_Authorization exists, THE Sandbox_Account root SHALL associate the sandbox VPC with the Platform_Zone
3. WHEN association is active, THE Test_EC2 in Dev_Account SHALL resolve `api.platform.{Demo_Domain}` to `10.0.1.10`
4. WHEN association is active, THE Test_EC2 in Sandbox_Account SHALL resolve `api.platform.{Demo_Domain}` to `10.0.1.10`

### Requirement 4: VPC Module

**User Story:** As a demo deployer, I want a reusable VPC with DNS enabled, so each account has a minimal network suitable for private DNS resolution.

#### Acceptance Criteria

1. THE VPC_Module SHALL enable DNS support and DNS hostnames on the VPC
2. THE VPC_Module SHALL create two private subnets across two availability zones
3. THE VPC_Module SHALL provision VPC endpoints for SSM (`ssm`, `ssmmessages`, `ec2messages`) so Test_EC2 instances are reachable without a bastion or public IP
4. THE VPC_Module SHALL output `vpc_id` for use by other modules

### Requirement 5: EC2-Based DNS Testing

**User Story:** As a presenter, I want one small EC2 instance per account to test DNS from inside each VPC, so I can prove resolution live with a simple shell command.

#### Acceptance Criteria

1. THE Test_EC2_Module SHALL provision one EC2 instance per account using the `instance_type` variable (default: `t4g.nano`)
2. THE Test_EC2_Module SHALL attach an IAM instance profile granting SSM Session Manager access
3. THE Test_EC2_Module SHALL NOT assign a public IP or require a bastion host
4. THE Test_EC2_Module SHALL place each instance in a private subnet from the VPC_Module
5. THE Walkthrough SHALL document connecting to each Test_EC2 via SSM Session Manager and running `dig api.platform.{Demo_Domain}` (or `nslookup`) to confirm resolution to `10.0.1.10`
6. THE Walkthrough SHALL document repeating the lookup from Central_Account, Dev_Account, and Sandbox_Account Test_EC2 instances
7. THE repository SHALL NOT include DNS verification scripts or any testing tooling beyond the EC2 instances themselves

### Requirement 6: Manual Phased Deployment Guide

**User Story:** As a presenter, I want documented phased `terraform apply` steps, so I can deploy the demo live and explain each dependency in order.

#### Acceptance Criteria

1. THE Walkthrough SHALL document Phase 1: apply dev and sandbox VPC-only roots and capture `vpc_id` outputs
2. THE Walkthrough SHALL document Phase 2: apply Central_Account using dev and sandbox `vpc_id` values to create the PHZ and authorizations
3. THE Walkthrough SHALL document Phase 3: apply dev and sandbox full roots to create VPC associations and Test_EC2 instances
4. THE Walkthrough SHALL list the exact `terraform` commands and working directories for each phase
5. THE Walkthrough SHALL explain why each phase must complete before the next begins

### Requirement 7: Manual Teardown Guide

**User Story:** As a presenter, I want documented `terraform destroy` steps in reverse dependency order, so I can clean up the demo manually.

#### Acceptance Criteria

1. THE Walkthrough SHALL document destroying Dev_Account and Sandbox_Account full configurations first
2. THE Walkthrough SHALL document destroying Central_Account second
3. THE Walkthrough SHALL document destroying dev and sandbox VPC-only configurations last
4. THE Walkthrough SHALL list the exact `terraform` commands and working directories for each destroy step

### Requirement 8: Terraform Validation

**User Story:** As a contributor, I want `terraform validate` to pass in all account roots before apply.

#### Acceptance Criteria

1. WHEN `terraform validate` runs in `terraform/accounts/central/`, THE Terraform_CLI SHALL report success
2. WHEN `terraform validate` runs in `terraform/accounts/dev/`, THE Terraform_CLI SHALL report success
3. WHEN `terraform validate` runs in `terraform/accounts/sandbox/`, THE Terraform_CLI SHALL report success

### Requirement 9: AWS Credential Configuration

**User Story:** As a deployer, I want Terraform to use my AWS CLI credentials, so I can target each account by setting `AWS_PROFILE` before each phased apply.

#### Acceptance Criteria

1. THE Central_Account, Dev_Account, and Sandbox_Account Terraform providers SHALL use the default AWS credential chain (no `assume_role` block in provider configuration)
2. THE account root providers SHALL apply default tags (`Project`, `Account`, `ManagedBy`) via a `default_tags` block
3. THE Walkthrough SHALL document setting `AWS_PROFILE` to the correct account profile before each `terraform apply`, `terraform destroy`, and `aws ssm start-session` command
4. THE Walkthrough SHALL document verifying the active account with `aws sts get-caller-identity`

### Requirement 10: Configuration Variables

**User Story:** As a deployer, I want environment-specific values as variables with sensible defaults.

#### Acceptance Criteria

1. THE Terraform configuration SHALL expose `aws_region` (default: `ap-southeast-2`)
2. THE Terraform configuration SHALL expose `project_name` (default: `r53demo`) and `account_name` (default per account root: `central`, `dev`, or `sandbox`) for provider default tags
3. THE Terraform configuration SHALL expose `demo_domain` (default: `demo.local`) on the central account root
4. THE Terraform configuration SHALL expose `instance_type` (default: `t4g.nano`)
5. THE central account root SHALL expose `dev_vpc_id` and `sandbox_vpc_id` for Phase 2
6. THE dev and sandbox account roots SHALL expose `zone_id`, `enable_zone_association`, and `enable_test_ec2` for phased deployment
7. THE repository SHALL include `terraform.tfvars.example` documenting phase-specific variables
8. EACH account root SHALL include a `versions.tf` declaring `required_version >= 1.5.0` and provider constraints

### Requirement 11: Repository Structure and Documentation

**User Story:** As a presenter, I want clear structure and docs, so the audience can follow and reproduce the classic association pattern.

#### Acceptance Criteria

1. THE repository SHALL include `docs/walkthrough.md` with architecture diagram, phased apply steps, EC2-based DNS testing, and teardown steps
2. THE repository SHALL organize modules under `terraform/modules/`: `vpc`, `private-hosted-zone`, `cross-account-auth`, and `test-ec2`
3. THE repository SHALL organize account roots under `terraform/accounts/`: `central`, `dev`, and `sandbox`, each with `versions.tf`, `providers.tf`, `main.tf`, `variables.tf`, `outputs.tf`, and `terraform.tfvars.example`
4. THE README SHALL link to the walkthrough and state that the demo uses classic VPC association authorization, not Route 53 Profiles or RAM
