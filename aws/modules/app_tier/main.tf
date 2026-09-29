variable "name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "data_volumes" {
  description = "Size in GiB of each extra gp3 data volume attached to every instance."
  type        = list(number)
  default     = []
}

variable "subnet_ids" {
  type = list(string)
}

resource "aws_instance" "this" {
  count = var.instance_count

  ami           = "ami-0fc5d935ebf8bc3bc" # Ubuntu 24.04 LTS
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  # One ebs_block_device per entry in data_volumes.
  dynamic "ebs_block_device" {
    for_each = var.data_volumes
    content {
      device_name = "/dev/sd${substr("fghijklmnop", ebs_block_device.key, 1)}"
      volume_type = "gp3"
      volume_size = ebs_block_device.value
    }
  }

  tags = { Name = "${var.name}-${count.index}" }
}

output "instance_ids" {
  value = aws_instance.this[*].id
}
