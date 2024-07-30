resource "aws_vpc" "vpc-sg" {
  cidr_block       = "10.0.128.0/17"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-sg"
  }
}

resource "aws_subnet" "pub-1" {
  vpc_id     = aws_vpc.vpc-sg.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  cidr_block = "10.0.208.0/20"

  tags = {
    Name = "pub-1"
  }
}

resource "aws_subnet" "pub-2" {
  vpc_id     = aws_vpc.vpc-sg.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  cidr_block = "10.0.224.0/19"

  tags = {
    Name = "pub-2"
  }
}

resource "aws_subnet" "pvt-1" {
  vpc_id     = aws_vpc.vpc-sg.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-2b"
  cidr_block = "10.0.128.0/18"

  tags = {
    Name = "pvt-1"
  }
}

resource "aws_subnet" "pvt-2" {
  vpc_id     = aws_vpc.vpc-sg.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-2b"
  cidr_block = "10.0.192.0/21"

  tags = {
    Name = "pvt-2"
  }
}

resource "aws_internet_gateway" "gw-sg" {
  vpc_id = aws_vpc.vpc-sg.id

  tags = {
    Name = "gw-sg"
  }
}

resource "aws_route_table" "route-sg" {
  vpc_id = aws_vpc.vpc-sg.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-sg.id
  } 
  tags = {
    Name = "route-sg"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pvt-1.id
  route_table_id = aws_route_table.route-sg.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pub-1.id
  route_table_id = aws_route_table.route-sg.id
}

