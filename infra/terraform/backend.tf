terraform {
  backend "s3" {
    bucket         = "terraform-state-crediya"
    key            = "infra/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-crediya"
    encrypt        = true
  }
}