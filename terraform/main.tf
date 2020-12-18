terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
    # Install the optional terraform-provider-infracost to enable estimation of usage-based resources such as Lambda
    infracost = { source = "infracost/infracost" }
  }
}
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}
provider "infracost" {}

variable "instance_type" {
  type = string
}

resource "aws_instance" "web_app" {
  ami           = "ami-674cbc1e"
  instance_type = var.instance_type

  root_block_device {
    volume_size = 50
  }

  ebs_block_device {
    device_name = "my_data"
    volume_type = "io1"
    volume_size = 50
    iops        = 200
  }
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"
  role          = "arn:aws:lambda:us-east-1:account-id:resource-id"
  handler       = "exports.test"
  runtime       = "nodejs12.x"
  memory_size   = 128
}

# Get cost estimates for Lambda requests and duration
data "infracost_aws_lambda_function" "hello_world" {
  resources = [aws_lambda_function.hello_world.id]
  monthly_requests { value = 100000000 }
  average_request_duration { value = 250 }
}
