provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Account   = var.account_name
      ManagedBy = "terraform"
    }
  }
}
