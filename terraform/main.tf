provider "aws" {
  region                      = "us-east-1" # <<<<< Try changing this to eu-west-1 to compare the costs
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

module "ec2-instance" {
  source  = "app.terraform.io/infracost/ec2-instance/aws"
  version = "2.16.0"

  name                   = "web-app"
  instance_count         = 1

  ami                    = "ami-674cbc1e"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-eddcdzz4"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"
  role          = "arn:aws:lambda:us-east-1:account-id:resource-id"
  handler       = "exports.test"
  runtime       = "nodejs12.x"
  memory_size   = 1024                      # <<<<< Try changing this to 512 to compare costs
}
