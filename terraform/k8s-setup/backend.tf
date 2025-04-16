terraform {
  backend "s3" {
    bucket         = "terraform-state-codeway"
    key            = "eks/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}