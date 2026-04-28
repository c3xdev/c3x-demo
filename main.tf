resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m6i.2xlarge"

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }
}

resource "aws_db_instance" "main" {
  engine         = "postgres"
  instance_class = "db.r5.xlarge"
  multi_az       = true
  allocated_storage = 200
}
