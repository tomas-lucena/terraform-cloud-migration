

resource "aws_subnet" "public" {
  count             = var.number_public_subnets
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.base_cidr_block, 8, count.index)
  tags = {
    Name = "tf_subnet_public_${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = var.number_private_subnets
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.base_cidr_block, 8, var.number_public_subnets + count.index)
  tags = {
    Name = "tf_subnet_private_${count.index + 1}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "tf_igw"
  }
}

# resource "aws_eip" "eip" {
#   tags = {
#     Name = "tf_eip"
#   }
# }


# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.public[0].id

#   tags = {
#     Name = "gw NAT"
#   }

#   depends_on = [aws_internet_gateway.igw]
# }

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.base_cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tf_rt_public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat.id
  # }
  route {
    cidr_block = var.base_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "tf_rt_private"
  }
}


resource "aws_route_table_association" "private" {
  count          = var.number_private_subnets
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = var.number_public_subnets
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id

}



resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  vpc_id              = var.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.sg_application_id]
  subnet_ids          = aws_subnet.private.*.id
  tags = {
    Name = "tf_endpoint_ecr_dkr"
  }

}

resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [var.sg_application_id]
  subnet_ids          = aws_subnet.private.*.id
  tags = {
    Name = "tf_endpoint_ecr_api"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  policy = jsonencode(
    {
      "Statement" : [
        {
          "Sid" : "Access-to-specific-bucket-only",
          "Principal" : "*",
          "Action" : [
            "s3:GetObject"
          ],
          "Effect" : "Allow",
          "Resource" : ["arn:aws:s3:::prod-us-east-1-starport-layer-bucket/*"]
        }
      ]
    }
  )
  tags = {
    Name = "tf_endpoint_s3"
  }
}


resource "aws_vpc_endpoint" "logs" {
  private_dns_enabled = true
  security_group_ids  = [var.sg_application_id]
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  subnet_ids          = aws_subnet.private.*.id

  tags = {
    Name = "tf_endpoint_ecr_logs"
  }
}
