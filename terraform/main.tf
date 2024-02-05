provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_web_app" {
  instance_type = "m3.xlarge"     # <<<<< Try changing this to m5.xlarge to compare the costs

  tags = {
    Environment = "production"
    Service = "web-app"
  }

  root_block_device {
    volume_size = 1000             # <<<<< Try adding volume_type="gp3" to compare costs
  }
}

resource "aws_lambda_function" "my_hello_world" {
  runtime = "nodejs12.x"
  memory_size = 512

  tags = {
    Environment = "Prod"
  }
}
