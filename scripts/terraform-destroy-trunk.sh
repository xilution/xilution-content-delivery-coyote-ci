#!/bin/bash -ex

terraform destroy \
  -var="organization_id=$XILUTION_ORGANIZATION_ID" \
  -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
  -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
  -var="client_aws_region=$CLIENT_AWS_REGION" \
  -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
  -var="xilution_aws_region=$XILUTION_AWS_REGION" \
  -var="xilution_environment=$XILUTION_ENVIRONMENT" \
  -var="xilution_pipeline_type=$PIPELINE_TYPE" \
  -auto-approve \
  ./terraform/trunk
