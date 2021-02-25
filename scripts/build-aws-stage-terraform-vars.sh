#!/bin/bash -e

[ -z "$XILUTION_ORGANIZATION_ID" ] && echo "Didn't find XILUTION_ORGANIZATION_ID env var." && exit 1
[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1
[ -z "$CLIENT_AWS_ACCOUNT" ] && echo "Didn't find CLIENT_AWS_ACCOUNT env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1
[ -z "$XILUTION_AWS_ACCOUNT" ] && echo "Didn't find XILUTION_AWS_ACCOUNT env var." && exit 1
[ -z "$XILUTION_AWS_REGION" ] && echo "Didn't find XILUTION_AWS_REGION env var." && exit 1
[ -z "$XILUTION_ENVIRONMENT" ] && echo "Didn't find XILUTION_ENVIRONMENT env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1

cat <<EOF >./tfvars.json
{
  "organization_id": "$XILUTION_ORGANIZATION_ID",
  "pipeline_id": "$PIPELINE_ID",
  "pipeline_type": "$PIPELINE_TYPE",
  "client_aws_account": "$CLIENT_AWS_ACCOUNT",
  "client_aws_region": "$CLIENT_AWS_REGION",
  "xilution_aws_account": "$XILUTION_AWS_ACCOUNT",
  "xilution_aws_region": "$XILUTION_AWS_REGION",
  "xilution_environment": "$XILUTION_ENVIRONMENT",
  "stage_name": "$STAGE_NAME"
}
EOF
