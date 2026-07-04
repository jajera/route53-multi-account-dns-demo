# Walkthrough Specification

Spec-level presenter guide — source for `docs/walkthrough.md` per `.config.kiro`.

## Architecture summary

Six stacks, three accounts, two regions (`ap-southeast-2`, `ap-southeast-6`), one PHZ in the **network** account.

Four association scenarios: cross-account same-region, cross-account cross-region, same-account cross-region (`network-apse6`), same-account same-region second VPC (`network` secondary).

Profiles: `r53demo-network`, `r53demo-dev`, `r53demo-sandbox`.

## Phases

1. **Phase 1** — all six stacks, VPCs only
2. **Phase 2a** — `network`: PHZ, secondary VPC association, four cross-account authorizations, 2× EC2
3. **Phase 2b** — `network-apse6`: same-account cross-region association + EC2
4. **Phase 3** — workload stacks: associations + EC2

## Intentionally excluded

Document in output walkthrough: Route 53 Profiles, RAM, query logging, DNS Firewall, alias records, DNSSEC, failover routing, second PHZ.

## Output

Full manual commands and troubleshooting live in `docs/walkthrough.md`.
