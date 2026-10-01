# VPC Networking

Terraform defines the Fider network in `platform/`, with remote state stored in S3.

## Design

VPC CIDR: `10.0.0.0/16`.

| Subnet | CIDR | Availability Zone |
| --- | --- | --- |
| Public A | `10.0.1.0/24` | `us-east-1a` |
| Public B | `10.0.2.0/24` | `us-east-1b` |
| Private A | `10.0.3.0/24` | `us-east-1a` |
| Private B | `10.0.4.0/24` | `us-east-1b` |

- Public subnets route internet traffic through the Internet Gateway.
- Private subnets use one NAT Gateway in Public A.
- One NAT reduces costs, but both private subnets depend on its Availability Zone for internet access.
- DNS resolution and DNS hostnames are enabled.

## Security

- ALB: inbound TCP `443` from the internet.
- Fider: inbound TCP `3000` from the ALB group.
- RDS: inbound TCP `5432` from the Fider group.
- The ALB needs outbound TCP 3000 access to Fider because it starts a separate connection when forwarding requests.
- Fider needs outbound TCP 5432 access to RDS to query the database.
- Replies are automatically allowed because security groups are stateful.
- Checkov (CKV2_AWS_12) flag :The default security group has no inbound or outbound rules, preventing accidental use.


## Validation and Follow-up

Applied 25 Terraform resources and checked routing and security groups in AWS.

Destroy the test network after verification to limit costs. The bootstrap state bucket remains.

VPC Flow Logs are deferred to monitoring. Security group attachments will be completed when the ALB, application infrastructure and RDS are deployed.

Evidence: `images/vpc-resource-map.png`.