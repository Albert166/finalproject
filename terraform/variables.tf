variable "aws_region" {
  description = "AWS region to deploy resources"
  # Change to yourr desired region
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_a" {
  description = "CIDR block for the Subnet"
  default     = "10.0.1.0/24"
}


variable "availability_zone_a" {
  description = "Availability zone for the Subnet"
  default     = "eu-central-1a"
}


variable "instance_type" {
  description = "Type of EC2 instance"
  # Change to your desired instance type
  default     = "t2.micro"
}

