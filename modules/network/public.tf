resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public0" {
  subnet_id      = aws_subnet.public0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public0" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet0_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet1_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
}
