provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "shopping-list-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "shopping-list-igw"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "shopping-lsit-table"
  }
}

# Subnet
resource "aws_subnet" "main-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_a
  availability_zone = var.availability_zone_a
  tags = {
    Name = "shopping-list-subnet"
  }
}

# Public Subnet

resource "aws_subnet" "main-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "shopping-list-subnet"
  }
}

# Security Group for HTTP so it would allow global connections from port 80
resource "aws_security_group" "https" {
  vpc_id = aws_vpc.main.id
  name   = "Allow Global HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "shopping-list-security-group"
    Source = "Global"
  }
}
# Security Group for ssh so that ansible can connect to ec2 instance though port 22
resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "shopping-list-ssh-security-group"
    Source = "Global"
  }
}
# Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main-b.id
  route_table_id = aws_route_table.main.id
}


# IAM Role
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "EC2_Cloudwatch_Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
  role       = aws_iam_role.ec2_cloudwatch_role.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_cloudwatch_profile" {
  name = "EC2_Cloudwatch_Profile"
  role = aws_iam_role.ec2_cloudwatch_role.name

}


# EC2 Instance
resource "aws_instance" "shopping_list_instance" {
  ami           = "ami-0a628e1e89aaedf80"
  instance_type = var.instance_type
  key_name = "shopping-list-key-pair"
  vpc_security_group_ids = [aws_security_group.https.id, aws_security_group.ssh.id]
  subnet_id = aws_subnet.main-b.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_cloudwatch_profile.name
  tags = {
    Name = "shopping-list-webapp-instance"
  }
}

