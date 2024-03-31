terraform {
  backend "s3" {
    bucket         = "ash2024terraformbucket"
    key            = "ash/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}