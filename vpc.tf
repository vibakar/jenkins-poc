resource "aws_vpc" "poc" {
  cidr_block           = var.VPC_CIDR_BLOCK
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { for k, v in var.TAGS : k => lower(v) }
}

resource "aws_subnet" "poc" {
  vpc_id                  = aws_vpc.poc.id
  cidr_block              = var.SUBNET_CIDR_BLOCK
  availability_zone       = var.SUBNET_AVAILABILITY_ZONE
  map_public_ip_on_launch = true

  tags = { for k, v in var.TAGS : k => lower(v) }
}

resource "aws_internet_gateway" "poc" {
  vpc_id = aws_vpc.poc.id

  tags = { for k, v in var.TAGS : k => lower(v) }
}

resource "aws_route_table" "poc" {
  vpc_id = aws_vpc.poc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc.id
  }

  tags = { for k, v in var.TAGS : k => lower(v) }
}

resource "aws_route_table_association" "poc" {
  subnet_id      = aws_subnet.poc.id
  route_table_id = aws_route_table.poc.id
}

resource "aws_security_group" "master" {
  name        = "master"
  description = "Security group for master"
  vpc_id      = aws_vpc.poc.id

  dynamic "ingress" {
    for_each = var.MASTER_SG_RULES_INGRESS
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      cidr_blocks = split(",", ingress.value["cidr_blocks"])
      protocol    = ingress.value["protocol"]
    }
  }

  dynamic "egress" {
    for_each = var.MASTER_SG_RULES_EGRESS
    content {
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      cidr_blocks = split(",", egress.value["cidr_blocks"])
      protocol    = egress.value["protocol"]
    }
  }

  tags = { for k, v in var.TAGS : k => lower(v) }
}

resource "aws_security_group" "agent" {
  name        = "agent"
  description = "Security group for agent"
  vpc_id      = aws_vpc.poc.id

  dynamic "ingress" {
    for_each = var.AGENT_SG_RULES_INGRESS
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      cidr_blocks = split(",", ingress.value["cidr_blocks"])
      protocol    = ingress.value["protocol"]
    }
  }

  dynamic "egress" {
    for_each = var.AGENT_SG_RULES_EGRESS
    content {
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      cidr_blocks = split(",", egress.value["cidr_blocks"])
      protocol    = egress.value["protocol"]
    }
  }
  tags = { for k, v in var.TAGS : k => lower(v) }
}