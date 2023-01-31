resource "aws_s3_bucket" "b" {
    count =4 
  bucket = random_string.random[count.index].id
}

resource "random_string" "random" {
    count = 4 
  length           = 16
  special          = false
  upper = false
}