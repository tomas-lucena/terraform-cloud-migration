output "private_subnets_id" {
  description = "Ids of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnets_id" {
  description = "Ids of public subnets"
  value       = aws_subnet.public[*].id
}

# output "vpc_id" {
#   value = aws_vpc.vpc.id
# }