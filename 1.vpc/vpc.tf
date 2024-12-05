resource "aws_vpc" "vpc" {
  cidr_block = var.base_cidr_block
  enable_dns_hostnames =  true
  enable_dns_support = true
  
  tags = {
    Name = "tf_vpc"
  }
}