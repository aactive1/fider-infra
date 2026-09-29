terraform {
  backend "s3" {
    bucket       = "aaden04-fider-terraform-state-us-east-1"
    key          = "platform/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}