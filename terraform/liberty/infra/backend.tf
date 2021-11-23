terraform {
  backend "s3" {
    bucket = "liberty-state-bucket"
    key    = "liberty-infra/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}
