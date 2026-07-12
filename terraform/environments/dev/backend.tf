terraform {
  backend "s3" {
    bucket       = "url-shortener-devops-tfstate-<your-account-id>"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}