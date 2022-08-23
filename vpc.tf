resource "aws_vpc" "vpc1" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  instance_tenancy     = "default"

  tags = {
    Name = format("%s-vpc1", var.projectPrefix)
  }
}

resource "aws_subnet" "vpc1_private" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = format("%sa", var.aws_region)

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
}


resource "aws_route_table" "vpc1_jump_rt_default" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }
  tags = {
    Name = "Local Route Table for private Subnet"
  }
}


resource "aws_route_table" "vpc1_workload_rt_default" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }
  tags = {
    Name = "Local Route Table for private Subnet"
  }
}

resource "aws_route_table_association" "vpc1_private_subnet_workload_ass" {
  subnet_id      = aws_subnet.vpc1_private.id
  route_table_id = aws_route_table.vpc1_workload_rt_default.id
}


resource "aws_security_group" "vpc1_ssh_allowed" {
  vpc_id = aws_vpc.vpc1.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}