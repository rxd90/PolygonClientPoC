# Data resource to get VPC with the tag "vpc_dev"
data "aws_vpcs" "vpc_dev" {
  filter {
    name   = "tag:Name"
    values = ["vpc_dev"]
  }
}

# Ensure only one VPC is returned
data "aws_vpc" "vpc_dev" {
  id = data.aws_vpcs.vpc_dev.ids[0]
}

# Data resource to get subnets with the tag "public_primary_dev"
data "aws_subnets" "public_primary_dev_subnets" {
  filter {
    name   = "tag:Name"
    values = ["public_primary_dev"]
  }
}

# Data resource to get subnets with the tag "public_secondary_dev"
data "aws_subnets" "public_secondary_dev_subnets" {
  filter {
    name   = "tag:Name"
    values = ["public_secondary_dev"]
  }
}