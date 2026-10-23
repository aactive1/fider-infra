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

Before destroying the AWS infrastructure, remove the Kubernetes resources that manage AWS load balancers.

**Important:** The EKS cluster and AWS Load Balancer Controller must still be running during this step.

### Step 1 — Remove Argo CD applications

This prevents Argo CD from recreating deleted Kubernetes resources.

```bash
kubectl delete application fider-dev -n argocd
kubectl delete application fider-test -n argocd
kubectl delete application fider-prod -n argocd
```

### Step 2 — Remove Kubernetes Ingress resources

```bash
kubectl delete ingress --all -n dev
kubectl delete ingress --all -n test
kubectl delete ingress --all -n prod
```

The AWS Load Balancer Controller will clean up the associated Application Load Balancers.

**Allow the ALBs to finish deleting before continuing.** Check the EC2 Load Balancers page in the AWS Console and confirm the Fider ALBs have disappeared.

### Step 3 — Destroy Terraform infrastructure

From the `platform` directory:

```bash
terraform destroy
```

Review the deletion plan before confirming.

### Important notes

- Do not destroy EKS before removing the ALBs.
- ALB network interfaces can prevent public subnets from being deleted.
- Do not manually delete ALB-managed network interfaces.
- Keep the Terraform bootstrap S3 state bucket until the platform has been destroyed.
- If EKS has already been deleted, remaining ALBs must be removed through AWS before Terraform can complete the network cleanup.
