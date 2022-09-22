terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"

    }
}
 backend "s3" {
   bucket         = "arq-s3-tfstate"
   key            = "terraform/dftfstate"
   region         = "eu-central-1"
   encrypt        = "false"
   dynamodb_table = "df-terraform-remote-state-dynamodb"
 }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Enviroment = "POC"
      Company    = "Corporación"
      ProjectName = "POC_DragonFly"

    }
  }

 
}