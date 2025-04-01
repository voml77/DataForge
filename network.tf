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
