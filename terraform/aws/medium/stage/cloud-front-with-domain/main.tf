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

resource "aws_acm_certificate" "certificate" {
  domain_name               = "${var.stage_name}.${var.domain}"
  subject_alternative_names = compact([var.stage_name == "prod" ? var.domain : null])
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    originator = "xilution.com"
  }
}

data "aws_ssm_parameter" "route53_zone_id" {
  name = "${var.domain}_route53-hosted-zone-name"
}

data "aws_route53_zone" "route53_zone" {
  name = data.aws_ssm_parameter.route53_zone_id.value
}

resource "aws_route53_record" "cert-validation-records" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation-records : record.fqdn]
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

  aliases = compact(concat(["${var.stage_name}.${var.domain}"], [var.stage_name == "prod" ? var.domain : null]))

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_ssm_parameter" "cloudfront-distribution-id" {
  name  = "xilution-coyote-${substr(var.pipeline_id, 0, 8)}-${lower(var.stage_name)}-cloudfront-distribution-id"
  type  = "String"
  value = aws_cloudfront_distribution.cloudfront-distribution.id
}
