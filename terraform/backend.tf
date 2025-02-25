terraform {
  backend "s3" {
    bucket         = "albertt-terraform-state"
    key            = "terraform/final-project/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "albertt-terraform-state-lock"
  }
}