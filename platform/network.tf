resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name      = "fider-vpc"
    Project   = "fider-eks"
    ManagedBy = "Terraform"

    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name      = "fider-public-subnet-a"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name      = "fider-public-subnet-b"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name      = "fider-private-subnet-a"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name      = "fider-private-subnet-b"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

