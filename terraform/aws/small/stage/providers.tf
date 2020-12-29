provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.client_aws_account}:role/xilution-developer-role"
  }
  region  = "us-east-1"
}
