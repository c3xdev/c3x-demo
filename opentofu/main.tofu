# OpenTofu 1.9+: one provider configuration per region with for_each,
# and resources fanned out across them. c3x prices every instance in the
# region of the provider it uses.

terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "regions" {
  description = "Regions the edge API is deployed to."
  type        = set(string)
  default     = ["us-east-1", "eu-west-1"]
}

provider "aws" {
  alias    = "by_region"
  for_each = var.regions
  region   = each.value
}

resource "aws_instance" "edge" {
  for_each = var.regions
  provider = aws.by_region[each.key]

  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "m7g.xlarge"

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
  }

  tags = { Name = "edge-api-${each.key}" }
}

resource "aws_elasticache_cluster" "sessions" {
  for_each = var.regions
  provider = aws.by_region[each.key]

  cluster_id      = "sessions-${each.key}"
  engine          = "redis"
  node_type       = "cache.r7g.large"
  num_cache_nodes = 1
}
