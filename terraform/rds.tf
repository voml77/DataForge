data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = "dataforge/rds/credentials"
}

resource "aws_db_instance" "dataforge_mysql" {
  identifier           = "dataforge-db"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "dataforge"
  username             = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)["username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)["password"]
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.dataforge_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.dataforge_subnet_group.name
}

resource "aws_db_subnet_group" "dataforge_subnet_group" {
  name       = "dataforge-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "DataForge DB Subnet Group"
  }
}

resource "aws_security_group" "dataforge_db_sg" {
  name        = "dataforge-db-sg"
  description = "Allow access from Glue or other VPC resources"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["82.135.77.122/32"] # Optional: begrenzen auf dein internes Netz
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DataForge DB SG"
  }
}
