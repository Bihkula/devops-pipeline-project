data "aws_availability_zones" "available" {
  state = "available"
}

# tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs -- No flow-log destination (CloudWatch/S3) provisioned yet for this learning VPC; low traffic, no active auditing need. Revisit in Phase 9 (observability) or Phase 12 (capstone).
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-pipeline-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-pipeline-igw"
  }
}

# tfsec:ignore:aws-ec2-no-public-ip-subnet -- Intentional: public-only subnets avoid the ~$32/month NAT Gateway cost for this learning project. kops nodes will run in public subnets. Revisit with private subnets + NAT in a hardening exercise.
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-pipeline-public-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "devops-pipeline-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
