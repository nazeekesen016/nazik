  terraform {
  backend "s3" {
    bucket = "news3bucketfornazik"
    key    = "allthefilesaregere/dev/terraform.tfstate"
    region = "eu-west-1"
  }
  }
