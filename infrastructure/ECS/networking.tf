# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ECS-VPC",
    managedBy = "Terraform"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ECS-IGW",
    managedBy = "Terraform"
  }
}

# Create 1 public and 2 pvt subnets
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "ECS-public-subnet-1",
    managedBy = "Terraform"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "ECS-public-subnet-2",
    managedBy = "Terraform"
  }
}

resource "aws_subnet" "pvt_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "ECS-pvt-subnet-1",
    managedBy = "Terraform"
  }
}

resource "aws_subnet" "pvt_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "ECS-pvt-subnet-2",
    managedBy = "Terraform"
  }
}

# Public route table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ecs-public-rt",
    managedBy = "Terraform"
  }
}

resource "aws_route_table_association" "pub_rt_association" {
  route_table_id = aws_route_table.pub-rt.id
  subnet_id      = aws_subnet.public_1.id
}

#EIP
resource "aws_eip" "eip" {
  tags = {
    Name = "ecs-nat-gw-eip",
    managedBy = "Terraform"
  }
}

# NAT
resource "aws_nat_gateway" "nat1" {
  subnet_id     = aws_subnet.public_1.id # The id in which to place the gateway
  allocation_id = aws_eip.eip.id

  tags = {
    Name = "ecs-nat-1",
    managedBy = "Terraform"
  }
}

resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "ecs-pvt-rt",
    managedBy = "Terraform"
  }
}

resource "aws_route_table_association" "pvt_rt_1_association" {
  route_table_id = aws_route_table.pvt_rt.id
  subnet_id      = aws_subnet.pvt_1.id
}

resource "aws_route_table_association" "pvt_rt_2_association" {
  route_table_id = aws_route_table.pvt_rt.id
  subnet_id      = aws_subnet.pvt_2.id
}