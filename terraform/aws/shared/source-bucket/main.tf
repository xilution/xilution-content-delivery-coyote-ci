# Source Bucket

resource "aws_s3_bucket" "source-bucket" {
  bucket        = "xilution-coyote-${substr(var.pipeline_id, 0, 8)}-source-code"
  force_destroy = true
  tags = {
    originator = "xilution.com"
  }
}
