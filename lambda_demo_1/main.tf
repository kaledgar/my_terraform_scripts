# prowider config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-west-1"
}
###############
# Create iam role for lambda
################
resource "aws_iam_role" "kkin_lambda_role" {
 name   = "terraform_aws_lambda_role"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
###############
# Create IAM policy for lambda
################
resource "aws_iam_policy" "kkin_iam_lambda_policy" {
  name = "kkinastowski_iam_policy_for_tf_lambda_role"
  path = "/"
  description = "kkinastowski_iam_policy_for_tf_lambda_role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
###############
# Attach policy to role
################
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.kkin_lambda_role.name
  policy_arn  = aws_iam_policy.kkin_iam_lambda_policy.arn
}
###############
# Generate .zip
################
data "archive_file" "zip_python_code" {
  type = "zip"
  source_dir = "${path.module}/python/"
  output_path = "${path.module}/python/lambda-python.zip"
}
###############
# Create Lambda function
################
resource "aws_lambda_function" "kkinastowski_tf_lambda" {
  filename = "${path.module}/python/lambda-python.zip"
  function_name = "kacper-kinastowski-demo-lambda-from-tf"
  role = aws_iam_role.kkin_lambda_role.arn
  handler = "lambda.lambda_handler"   # "python_filename.python_functionname"
  runtime = "python3.9"
  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  tags = {
    Name = "kkinastowski-lambda-from-terraform-name-from-tag"
    "expiration_date" = "20-08-2023"
  }
}

## OUTPUTS

output "teraform_aws_role_output" {
 value = aws_iam_role.kkin_lambda_role.name
}

output "teraform_aws_role_arn_output" {
 value = aws_iam_role.kkin_lambda_role.arn
}

output "teraform_logging_arn_output" {
 value = aws_iam_policy.kkin_iam_lambda_policy.arn
}




/*
###############
# Create S3 Resource
################
resource "aws_s3_bucket" "bucket1" {
  bucket = var.bucket_name
  
  tags = {
    Name = var.bucket_name
    Environment = "Dev"
    expiration_date = "25-08-2023"
  }
}
###############
# Create ec2 and upload app1-install.sh
################
resource "aws_instance" "kkinastowski-demo-from-tf" {
  ami = "ami-0ed752ea0f62749af"
  instance_type = "t2.micro"
  user_data = file("${path.module}/app1-install.sh")
  tags = {
    "expiration_date" = "25-08-2023"
    "author" = "Kacper K"
  }
}
*/