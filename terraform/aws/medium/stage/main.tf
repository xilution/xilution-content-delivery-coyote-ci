module "cloud-front-with-domain" {
  count                = var.domain ? 1 : 0
  source               = "./cloud-front-with-domain"
  client_aws_account   = var.client_aws_account
  client_aws_region    = var.client_aws_region
  domain               = var.domain
  organization_id      = var.organization_id
  pipeline_id          = var.pipeline_id
  pipeline_type        = var.pipeline_type
  stage_name           = var.stage_name
  xilution_aws_account = var.xilution_aws_account
  xilution_aws_region  = var.xilution_aws_region
  xilution_environment = var.xilution_environment
}

module "cloud-front-without-domain" {
  count                = var.domain ? 0 : 1
  source               = "./cloud-front-without-domain"
  client_aws_account   = var.client_aws_account
  client_aws_region    = var.client_aws_region
  organization_id      = var.organization_id
  pipeline_id          = var.pipeline_id
  pipeline_type        = var.pipeline_type
  stage_name           = var.stage_name
  xilution_aws_account = var.xilution_aws_account
  xilution_aws_region  = var.xilution_aws_region
  xilution_environment = var.xilution_environment
}
