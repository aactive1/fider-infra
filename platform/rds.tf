resource "aws_db_subnet_group" "fider_rds_subnet_group" {
  name       = "fider-rds-private-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name      = "fider-rds-private-subnet-group"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}