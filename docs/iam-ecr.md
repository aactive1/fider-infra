# IAM and ECR

## Design

Terraform defines a private Fider ECR repository and separate IAM roles for CI, the EKS cluster and worker nodes.

- GitHub Actions authenticates through OIDC without stored AWS access keys.
- The CI role trusts only the Fider app repository on `main`, including its immutable owner and repository IDs.
- Upload permissions are restricted to Fider’s ECR repository.
- EKS cluster and node roles use separate AWS-managed policies. Nodes have image-pull permissions.

## Image Publishing

Pull requests run checks without publishing. Successful pushes to `main` build, scan and upload the same image without rebuilding it.

Images use Git commit SHA tags. ECR prevents tag overwrites and scans images on push. The lifecycle policy expires untagged images after seven days; tagged-image retention remains future work.

Default AES-256 encryption is retained, with a documented Checkov exception for KMS.

## Verification and Troubleshooting

- Verified successful OIDC authentication and SHA-tagged image publishing to ECR.
- Trivy blocked publishing because of vulnerabilities in the runtime’s `perl-base` package. Explicitly updating that package and rebuilding produced a passing scan.
- Terraform reported no changes after deployment.

