variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for every resource."
  type        = string
  default     = "shop"
}

variable "az_count" {
  description = "Number of availability zones to spread the VPC across. Each one gets its own NAT gateway."
  type        = number
  default     = 3
}

# One module instance per application tier (module for_each).
variable "tiers" {
  description = "Application tiers, each an independent group of EC2 instances."
  type = map(object({
    instance_type  = string
    instance_count = number
    data_volumes   = list(number) # extra gp3 volumes, in GiB, per instance
  }))
  default = {
    web = {
      instance_type  = "m7i.large"
      instance_count = 3
      data_volumes   = []
    }
    worker = {
      instance_type  = "c7i.xlarge"
      instance_count = 2
      data_volumes   = [100, 200]
    }
  }
}
