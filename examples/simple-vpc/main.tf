provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source = "../../module"

  name = "simple-vpc-example"

  cidr = "10.0.0.0/16"

  azs             = ["us-west-1a", "us-west-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  assign_generated_ipv6_cidr_block = false


  private_subnet_tags = {
    Name = "example001"
  }

  tags = {
    Owner       = "eng"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}
