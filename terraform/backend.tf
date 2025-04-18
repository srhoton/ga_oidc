terraform {
  backend "s3" {
    bucket = "srhoton-tfstate"
    key    = "ga-oidc/terraform.tfstate"
    region = "us-east-1"
  }
}
