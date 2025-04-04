variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "eu-central-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_route_tables" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_vpc_endpoint" "existing_s3" {
  filter {
    name   = "service-name"
    values = ["com.amazonaws.${var.aws_region}.s3"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow-mysql-access"
  description = "Allow MySQL inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow MySQL from your IP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["82.135.77.122/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowMySQL"
  }
}