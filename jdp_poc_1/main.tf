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
  region = var.region
}

# Create S3 Resource for location of db
resource "aws_s3_bucket" "s3_database_location" {
  bucket = var.db_location_bucket_name
  
  tags = {
    Name = var.db_location_bucket_name
    expiration_date = var.expiration_date_tag
  }
}

# Create role for glue to read
resource "aws_iam_role" "terraform_aws_glue_role" {
  name               = "terraform_aws_glue_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


/*
# TO DEPLOY ONE DAY
# glue job
resource "aws_glue_job" "glue-job-demo" {
  name     = "glue-job-demo"
  role_arn = aws_iam_role.terraform_aws_glue_role.arn
  command {
    script_location = "s3://${aws_s3_bucket.example.bucket}/example.py"
  }
}
*/


## Create Glue Catalog Database
resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "kkinastowski_glue_catalog_database"

  location_uri = "s3://${var.db_location_bucket_name}"
  #location_uri = var.glue_db_catalog_location
  tags = {
    expiration_date = var.expiration_date_tag
  }
}


## Source code example: https://registry.terraform.io/providers/figma/aws-4-49-0/latest/docs/resources/glue_catalog_table
resource "aws_glue_catalog_table" "aws_glue_catalog_table_example" {
  name          = "kkinastowski_glue_catalog_table"
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = var.glue_db_catalog_table_location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "Name"
      type = "string"
    }

    columns {
      name = "Salary"
      type = "double"
    }

    columns {
      name    = "Date"
      type    = "date"
      comment = ""
    }

    columns {
      name    = "ID"
      type    = "bigint"
      comment = ""
    }

    columns {
      name    = "Struct"
      type    = "struct<my_nested_string:string>"
      comment = ""
    }
  }
}

## Source Table
resource "aws_glue_catalog_table" "aws_glue_catalog_table_source" {
  name          = "kkinastowski_source_table"
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
}

## Target Table
resource "aws_glue_catalog_table" "aws_glue_catalog_table_target" {
  name          = "kkinastowski_target_table"
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
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