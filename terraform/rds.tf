data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = "dataforge/rds/mysql_credentials"
}

resource "aws_db_instance" "dataforge_mysql" {
  identifier           = "dataforge-mysql"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "dataforge"
  username             = "vadimadmin"
  password             = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["rds_password"]
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
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
    cidr_blocks = ["10.0.0.0/16"] # Optional: begrenzen auf dein internes Netz
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
