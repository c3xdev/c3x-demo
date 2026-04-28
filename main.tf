resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m5.xlarge"

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
}

resource "aws_db_instance" "main" {
  engine         = "postgres"
  instance_class = "db.r5.large"
  multi_az       = true
  allocated_storage = 100
}
