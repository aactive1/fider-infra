# Fider Infrastructure — Deployment Runbook

This runbook explains how to provision the AWS infrastructure used by the Fider EKS project.

Infrastructure is managed using Terraform and deployed in `us-east-1`.

## Prerequisites

Install:

- Terraform
- AWS CLI
- Git
- kubectl

You will need an AWS account with permissions to create the required infrastructure.

**AWS charges apply while the resources are running**, particularly EKS, EC2, NAT Gateway and RDS.

## 1. Configure AWS CLI

Configure your AWS credentials using your preferred IAM identity or AWS profile.

For standard local configuration:

```bash
aws configure
```

Select `us-east-1` as the default region.

Avoid using AWS root account credentials for routine Terraform operations.

## 2. Clone the repository

```bash
git clone https://github.com/aactive1/fider-infra.git
```

```bash
cd fider-infra
```

## 3. Configure Terraform

Before running Terraform, review the configuration in `bootstrap/` and `platform/`.

Update any account-specific or deployment-specific settings, including:

- AWS region and account-specific values.
- Terraform backend S3 bucket name.
- EKS cluster and node group configuration.
- Networking and database settings.
- IAM and OIDC configuration used by GitHub Actions.

The platform's S3 backend must refer to the state bucket created during the bootstrap stage.

## 4. Create Terraform Remote State

Open the bootstrap directory:

```bash
cd bootstrap
```

Initialise Terraform:

```bash
terraform init
```

Create the state infrastructure:

```bash
terraform apply
```

Review the proposed changes and enter `yes` to confirm.

The bootstrap stage provisions the remote state resources used by the main Terraform configuration.

## 5. Provision AWS Infrastructure

Return to the repository root:

```bash
cd ..
```

Open the platform directory:

```bash
cd platform
```

Initialise Terraform:

```bash
terraform init
```

Apply the infrastructure:

```bash
terraform apply
```

Review the proposed changes and enter `yes` to confirm.

Terraform provisions the main AWS resources, including:

- VPC and subnet networking
- Internet Gateway, routing and NAT Gateway
- Amazon EKS and managed worker nodes
- RDS PostgreSQL
- Amazon ECR
- IAM roles and Pod Identity associations
- S3 storage
- Supporting security configuration

## 6. Connect to Amazon EKS

Once Terraform has finished, configure kubectl:

```bash
aws eks update-kubeconfig --region us-east-1 --name fider-eks
```

This allows kubectl to communicate with the EKS cluster.

## 7. Deploy the Application

AWS infrastructure is now provisioned.

The next stage is to install the Kubernetes components and deploy Fider.

Follow the **[fider-gitops runbook](https://github.com/aactive1/fider-gitops/blob/main/docs/runbook.md)** for:

- External Secrets Operator
- AWS Load Balancer Controller
- Kubernetes namespaces and ExternalSecrets
- Argo CD
- Fider deployments
- Prometheus and Grafana

A fresh RDS deployment can generate a new database endpoint and Secrets Manager ARN. These must be reflected in the GitOps configuration.

An ACM certificate and a domain are also required for the HTTPS ingress setup.

## 8. Destroy Infrastructure

When the AWS resources are no longer needed, they can be removed using Terraform.

First remove application-level Kubernetes resources that create AWS load balancers and other external dependencies.

From the `platform` directory:

```bash
terraform destroy
```

Review the deletion plan before confirming.

**Important:** Do not destroy the bootstrap state infrastructure while Terraform still depends on it. Keep the S3 state bucket until the platform has been fully removed and its state has been safely handled.

Some resources, such as versioned S3 buckets, may require additional cleanup before deletion.

## Notes

- Terraform state is stored remotely in S3.
- Bootstrap and platform use separate state files.
- AWS infrastructure should be deployed before the Kubernetes components.
- Recreating infrastructure may change RDS endpoints, secret ARNs, load balancer addresses and other resource identifiers.
- Do not commit credentials or sensitive Terraform values to Git.
