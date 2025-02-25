variable "aws_region" {
  description = "AWS region to deploy resources"
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
  default     = "t2.micro"
}

variable "backend_bucket" {
  description = "Name of the S3 bucket to store the Terraform state"
  default     = "albertt-terraform-state"
}

variable "backend_key" {
  description = "Key of the S3 bucket to store the Terraform state"
  default     = "terraform/final-project/terraform.tfstate"
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB table to store the Terraform state lock"
  default     = "albertt-terraform-state-lock"
}