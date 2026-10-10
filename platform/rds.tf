resource "aws_db_subnet_group" "fider_rds_subnet_group" {
  name       = "fider-rds-private-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name      = "fider-rds-private-subnet-group"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_db_instance" "fider_rds_instance" {
  engine                      = "postgres"
  instance_class              = "db.t3.micro"
  multi_az                    = false
  allocated_storage           = 20
  db_subnet_group_name        = aws_db_subnet_group.fider_rds_subnet_group.name
  publicly_accessible         = false
  db_name                     = "fiderdb"
  username                    = "fideradmin"
  port                        = 5432
  manage_master_user_password = true
  storage_encrypted           = true
  vpc_security_group_ids      = [aws_security_group.rds-sg.id]
  backup_retention_period     = 1
  skip_final_snapshot         = true
  delete_automated_backups    = true
  deletion_protection         = false

}