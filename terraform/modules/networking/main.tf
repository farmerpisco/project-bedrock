resource "aws_vpc" "pb_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

data "aws_availability_zones" "pb_az" {
  state = "available"
}

resource "aws_subnet" "pb_public_subnet" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.pb_az.names[count.index]
  vpc_id                  = aws_vpc.pb_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                                    = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                                = "1"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

resource "aws_subnet" "pb_private_subnet" {
  count             = 2
  availability_zone = data.aws_availability_zones.pb_az.names[count.index]
  vpc_id            = aws_vpc.pb_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 10)

  tags = {
    Name                                                    = "${var.project_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"                       = "1"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

resource "aws_internet_gateway" "pb_igw" {
  vpc_id = aws_vpc.pb_vpc.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

resource "aws_eip" "pb_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.pb_igw]
}

resource "aws_nat_gateway" "pb_nat_gw" {
  allocation_id = aws_eip.pb_nat_eip.id
  subnet_id     = aws_subnet.pb_public_subnet[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.pb_igw]
}

resource "aws_route_table" "pb_public_rt" {
  vpc_id = aws_vpc.pb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pb_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.pb_public_subnet)
  subnet_id      = aws_subnet.pb_public_subnet[count.index].id
  route_table_id = aws_route_table.pb_public_rt.id
}

resource "aws_route_table" "pb_private_rt" {
  vpc_id = aws_vpc.pb_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pb_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.pb_private_subnet)
  subnet_id      = aws_subnet.pb_private_subnet[count.index].id
  route_table_id = aws_route_table.pb_private_rt.id
}

resource "aws_security_group" "pb_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for project bedrock"
  vpc_id      = aws_vpc.pb_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-security-group"
  }
}

resource "aws_security_group" "pb_eks_cluster_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.pb_vpc.id

  ingress {
    from_port   = 433
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-cluster-sg"
  }
}

resource "aws_security_group" "pb_rds_sg" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = aws_vpc.pb_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.pb_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.pb_eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_subnet_group" "pb_rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = aws_subnet.pb_private_subnet[*].id

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}


