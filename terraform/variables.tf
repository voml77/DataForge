variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the RDS instance"
  type        = string
}
