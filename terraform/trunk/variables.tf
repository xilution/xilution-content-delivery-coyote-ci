variable "organization_id" {
  type        = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "product_id" {
  type        = string
  description = "The Product ID"
  default     = "c3d91f28476048d38a7259a9eddd1025"
}

variable "coyote_pipeline_id" {
  type        = string
  description = "The Coyote Pipeline ID"
}

variable "client_aws_account" {
  type        = string
  description = "The Xilution Client AWS Account ID"
}

variable "client_aws_region" {
  type        = string
  description = "The Xilution Client AWS Region"
}

variable "xilution_aws_account" {
  type        = string
  description = "The Xilution AWS Account ID"
}

variable "xilution_aws_region" {
  type        = string
  description = "The Xilution AWS Region"
}

variable "xilution_environment" {
  type        = string
  description = "The Xilution Environment"
}

variable "xilution_pipeline_type" {
  type        = string
  description = "The Pipeline Type"
}
