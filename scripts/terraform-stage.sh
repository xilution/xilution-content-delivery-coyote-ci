#!/bin/bash -e

direction=${1}
awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${COYOTE_PIPELINE_ID}
stageName=${STAGE_NAME}

terraform init \
  -backend-config="key=xilution-content-delivery-coyote/${pipelineId}/${stageName}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/stage

if [[ "${direction}" == "up" ]]; then

  terraform plan \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
    -var="stage_name=$STAGE_NAME" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    ./terraform/stage

  terraform apply \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
    -var="stage_name=$STAGE_NAME" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -auto-approve \
    ./terraform/stage

elif [[ "${direction}" == "down" ]]; then

  terraform destroy \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
    -var="stage_name=$STAGE_NAME" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -auto-approve \
    ./terraform/stage

fi

echo "All Done!"
