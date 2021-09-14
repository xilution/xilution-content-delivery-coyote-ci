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

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  tags = {
    originator = "xilution.com"
    name       = local.s3_origin_id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_ssm_parameter" "cloudfront-distribution-id" {
  name  = "xilution-coyote-${substr(var.pipeline_id, 0, 8)}-${lower(var.stage_name)}-cloudfront-distribution-id"
  type  = "String"
  value = aws_cloudfront_distribution.cloudfront-distribution.id
}