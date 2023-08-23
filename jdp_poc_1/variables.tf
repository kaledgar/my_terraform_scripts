variable "region" {
  type = string
  default = "eu-west-1"
}

variable "db_location_bucket_name" {
  type = string
  default = "kkinastowski-db-storage" 
}

variable "expiration_date_tag" {
    type = string
    default = "28-08-2023"
}

variable "glue_db_catalog_location" {
  type = string
  default = "s3://kkinastowski-poc2-bucket-from-tf-variable/database/"
}

variable "glue_db_catalog_table_location" {
  type = string
  default = "s3://kkinastowski-poc2-bucket-from-tf-variable/database/"
}
