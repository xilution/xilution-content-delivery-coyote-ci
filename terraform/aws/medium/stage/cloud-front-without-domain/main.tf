resource "aws_s3_bucket" "static_content_bucket" {
  bucket        = "xilution-coyote-${substr(var.pipeline_id, 0, 8)}-${lower(var.stage_name)}-web-content"
  acl           = "private"
  force_destroy = true
  tags = {
    originator = "xilution.com"
  }
}

locals {
  s3_origin_id = aws_s3_bucket.static_content_bucket.id
}

resource "aws_cloudfront_distribution" "cloudfront-distribution" {
  comment = local.s3_origin_id

  origin {
    domain_name = aws_s3_bucket.static_content_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code = 403
    response_code = 200
    error_caching_min_ttl = 0
    response_page_path = "/index.html"
  }

  tags = {
    originator = "xilution.com"
    name       = local.s3_origin_id
  }
}

resource "aws_ssm_parameter" "cloudfront-distribution-id" {
  name  = "xilution-coyote-${substr(var.pipeline_id, 0, 8)}-${lower(var.stage_name)}-cloudfront-distribution-id"
  type  = "String"
  value = aws_cloudfront_distribution.cloudfront-distribution.id
}
