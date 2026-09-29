# Terraform Foundation

## What This Sets Up

`bootstrap/` creates the S3 bucket for Terraform state. `platform/` will build the VPC, EKS and supporting AWS resources. They share one bucket but use separate state keys: `bootstrap/terraform.tfstate` and `platform/terraform.tfstate`.

The bootstrap configuration first created the bucket with local state. I then ran `terraform init -migrate-state` to move that state to S3. Both configurations use S3 lockfiles to prevent simultaneous state writes.

## Security Choices

The state bucket blocks public access, enables versioning and SSE-S3 encryption and has Terraform deletion protection. Checkov found five additional S3 recommendations. I reviewed and documented specific exceptions for event notifications, access logging, object lifecycle rules, cross-region replication and SSE-KMS.

State may contain sensitive values. Local state, backups and `.terraform/` are excluded from Git; provider lock files are committed.

## Evidence

- `terraform state list` showed the four bootstrap resources after migration; `terraform plan` showed **No changes**.
- TFLint with AWS rules passed in both directories.
- Checkov reported **11 passed, 0 failed, 5 explained skips** for bootstrap.
- Pre-commit runs Terraform formatting and TFLint before local commits.

## Run the Checks

Run Terraform commands from the relevant directory. Use `terraform init` before the first plan in a fresh checkout.

```bash
py -m pre_commit run --all-files
py -m checkov.main --directory bootstrap --framework terraform
py -m checkov.main --directory platform --framework terraform