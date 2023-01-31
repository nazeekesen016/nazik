  terraform {
  backend "s3" {
    bucket = "news3bucketfornazik"
    key    = "allthefilesaregere/dev/vpc/terraform.tfstate"
    region = "eu-west-1"
  }
  }
