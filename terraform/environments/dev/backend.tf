terraform {
  backend "s3" {
    bucket       = "url-shortener-devops-tfstate-904233090074"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}