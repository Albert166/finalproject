terraform {
  backend "s3" {
    # Replace with your bucket name
    bucket         = "albertt-terraform-state"
    # Replace with your desired key name
    key            = "terraform/final-project/terraform.tfstate"
    # Replace with the region in which your bucket was created
    region         = "eu-central-1"
    encrypt        = true
    # Replace with your DynamoDB table name
    dynamodb_table = "albertt-terraform-state-lock"
  }
}