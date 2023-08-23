# Create S3 Resource for location of db
resource "aws_s3_bucket" "s3_database_location" {
  bucket = var.db_location_bucket_name

  tags = {
    Name            = var.db_location_bucket_name
    expiration_date = var.expiration_date_tag
  }
}

# Create Folder Structure from var.s3_folder on S3
resource "aws_s3_object" "data_directory_object" {
  bucket = aws_s3_bucket.s3_database_location.bucket
  count   = "${length(var.s3_folders)}"
  key    = "${var.s3_folders[count.index]}/"
}
