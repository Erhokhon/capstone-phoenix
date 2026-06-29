terraform {
  backend "s3" {
    bucket         = "solomon-phoenix-tf-state-174772361223"
    key            = "terraform-backend/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "phoenix-tf-locks"
    encrypt        = true
  }
}