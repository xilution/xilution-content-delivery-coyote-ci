resource "aws_s3_bucket" "static_content_bucket" {
  bucket = "xilution-coyote-${substr(var.pipeline_id, 0, 8)}-${lower(var.stage_name)}-web-content"
  acl    = "public-read"
  force_destroy = true
  website {
    index_document = "index.html"
  }
  tags = {
    originator = "xilution.com"
  }
}
