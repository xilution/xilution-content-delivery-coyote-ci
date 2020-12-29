#!/bin/bash -e

cat <<EOF >./tfvars.json
{
  "organization_id": "$XILUTION_ORGANIZATION_ID",
  "pipeline_id": "$PIPELINE_ID",
  "pipeline_type": "$PIPELINE_TYPE",
  "client_aws_account": "$CLIENT_AWS_ACCOUNT",
  "client_aws_region": "$CLIENT_AWS_REGION",
  "xilution_aws_account": "$XILUTION_AWS_ACCOUNT",
  "xilution_aws_region": "$XILUTION_AWS_REGION",
  "xilution_environment": "$XILUTION_ENVIRONMENT"
}
EOF
