resource "aws_security_group" "alb-sg" {
  name        = "fider-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name      = "fider-alb-sg"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress" {
  security_group_id = aws_security_group.alb-sg.id
  description       = "Allow HTTPS traffic from the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

}

resource "aws_security_group" "fider-sg" {
  name        = "fider-sg"
  description = "Security group for the Fider application"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name      = "fider-sg"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fider_sg_ingress" {
  security_group_id            = aws_security_group.fider-sg.id
  description                  = "Allow traffic from the ALB security group"
  referenced_security_group_id = aws_security_group.alb-sg.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000

}

resource "aws_security_group" "rds-sg" {
  name        = "fider-rds-sg"
  description = "Security group for the RDS instance"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name      = "fider-rds-sg"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_sg_ingress" {
  security_group_id            = aws_security_group.rds-sg.id
  description                  = "Allow traffic from the eks worker nodes"
  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "alb_sg_egress" {
  security_group_id            = aws_security_group.alb-sg.id
  description                  = "Allow outbound traffic to the Fider on TCP port 3000"
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  referenced_security_group_id = aws_security_group.fider-sg.id

}

resource "aws_vpc_security_group_egress_rule" "fider_sg_egress" {
  security_group_id            = aws_security_group.fider-sg.id
  description                  = "Allow outbound traffic to the RDS on TCP port 5432"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.rds-sg.id
}
