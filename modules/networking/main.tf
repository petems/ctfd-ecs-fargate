# VPC - Conditional creation based on existing_vpc_id
resource "aws_vpc" "main" {
  count                = var.existing_vpc_id == "" ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# Data source for existing VPC
data "aws_vpc" "existing" {
  count = var.existing_vpc_id != "" ? 1 : 0
  id    = var.existing_vpc_id
}

# Local values for VPC reference
locals {
  vpc_id         = var.existing_vpc_id != "" ? data.aws_vpc.existing[0].id : aws_vpc.main[0].id
  vpc_cidr_block = var.existing_vpc_id != "" ? data.aws_vpc.existing[0].cidr_block : aws_vpc.main[0].cidr_block
  private_subnet_ids = length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : aws_subnet.private[*].id
}

data "aws_region" "current" {}

# Internet Gateway - Conditional creation based on existing VPC
resource "aws_internet_gateway" "main" {
  count  = var.existing_vpc_id == "" ? 1 : 0
  vpc_id = local.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

# Public Subnets - Conditional creation based on existing subnets
resource "aws_subnet" "public" {
  count                   = length(var.existing_public_subnet_ids) == 0 ? length(var.public_subnet_cidrs) : 0
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Type = "Public"
  })
}

# Data source for existing public subnets
data "aws_subnet" "existing_public" {
  count = length(var.existing_public_subnet_ids)
  id    = var.existing_public_subnet_ids[count.index]
}

# Private Subnets - Conditional creation based on existing subnets
resource "aws_subnet" "private" {
  count             = length(var.existing_private_subnet_ids) == 0 ? length(var.private_subnet_cidrs) : 0
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Type = "Private"
  })
}

# Data source for existing private subnets
data "aws_subnet" "existing_private" {
  count = length(var.existing_private_subnet_ids)
  id    = var.existing_private_subnet_ids[count.index]
}

# Database Subnets - Conditional creation based on existing subnets
resource "aws_subnet" "database" {
  count             = length(var.existing_database_subnet_ids) == 0 ? length(var.database_subnet_cidrs) : 0
  vpc_id            = local.vpc_id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-database-subnet-${count.index + 1}"
    Type = "Database"
  })
}

# Data source for existing database subnets
data "aws_subnet" "existing_database" {
  count = length(var.existing_database_subnet_ids)
  id    = var.existing_database_subnet_ids[count.index]
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway && length(var.existing_public_subnet_ids) == 0 ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-eip-nat-${count.index + 1}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway && length(var.existing_public_subnet_ids) == 0 ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-gateway-${count.index + 1}"
  })
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  count  = length(var.existing_public_subnet_ids) == 0 ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  count  = length(var.existing_private_subnet_ids) == 0 ? (var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 1) : 0
  vpc_id = local.vpc_id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
  })
}

# Route Table for Database Subnets
resource "aws_route_table" "database" {
  count  = length(var.existing_database_subnet_ids) == 0 ? 1 : 0
  vpc_id = local.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-database-rt"
  })
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count          = length(var.existing_public_subnet_ids) == 0 ? length(var.public_subnet_cidrs) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count          = length(var.existing_private_subnet_ids) == 0 ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# Route Table Associations - Database
resource "aws_route_table_association" "database" {
  count          = length(var.existing_database_subnet_ids) == 0 ? length(var.database_subnet_cidrs) : 0
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = local.vpc_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/flowlogs/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  })
}

resource "aws_iam_role" "flow_log" {
  name = "${var.project_name}-${var.environment}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_log" {
  name = "${var.project_name}-${var.environment}-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.vpc_flow_log.arn
      }
    ]
  })
}

# Collect route table IDs for gateway endpoint association
locals {
  route_table_ids_for_gateway = concat(
    length(var.existing_public_subnet_ids)   == 0 ? [aws_route_table.public[0].id] : [],
    length(var.existing_private_subnet_ids)  == 0 ? aws_route_table.private[*].id : [],
    length(var.existing_database_subnet_ids) == 0 ? [aws_route_table.database[0].id] : []
  )
}

# Gateway VPC endpoint for S3 (required by ecr.dkr pull path)
resource "aws_vpc_endpoint" "s3_gateway" {
  count               = var.enable_gateway_endpoints ? 1 : 0
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = var.enable_gateway_endpoints ? (length(local.route_table_ids_for_gateway) > 0 ? local.route_table_ids_for_gateway : []) : []

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpce-s3-gateway"
  })
}

# Security group for Interface VPC Endpoints
resource "aws_security_group" "vpce" {
  count       = var.enable_interface_endpoints ? 1 : 0
  name        = "${var.project_name}-${var.environment}-vpce"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-vpce" })
}

# Interface VPC Endpoints for AWS services (e.g., secretsmanager, kms, ecr.api, ecr.dkr, logs, sts)
resource "aws_vpc_endpoint" "interface" {
  for_each            = var.enable_interface_endpoints ? toset(var.interface_endpoint_services) : []
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpce-${each.value}"
  })
}