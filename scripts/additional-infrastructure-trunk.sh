#!/bin/bash -ex

direction=${1}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
terraformModuleDir=$(jq -r ".additionalInfrastructure?.trunk?.terraformModuleDir" <./xilution.json)

echo "terraformModuleDir = ${terraformModuleDir}"

if [[ "${terraformModuleDir}" != "null" ]]; then

  terraform init \
    -backend-config="key=xilution-content-delivery-coyote/${COYOTE_PIPELINE_ID}/additional-infrastructure.tfstate" \
    -backend-config="bucket=xilution-terraform-backend-state-bucket-${CLIENT_AWS_ACCOUNT}" \
    -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
    "${terraformModuleDir}"

  if [[ "${direction}" == "up" ]]; then

    terraform plan \
      -var="organization_id=$XILUTION_ORGANIZATION_ID" \
      -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
      -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
      -var="client_aws_region=$CLIENT_AWS_REGION" \
      -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
      -var="xilution_aws_region=$XILUTION_AWS_REGION" \
      -var="xilution_environment=$XILUTION_ENVIRONMENT" \
      -var="xilution_pipeline_type=$PIPELINE_TYPE" \
      "${terraformModuleDir}"

    terraform apply \
      -var="organization_id=$XILUTION_ORGANIZATION_ID" \
      -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
      -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
      -var="client_aws_region=$CLIENT_AWS_REGION" \
      -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
      -var="xilution_aws_region=$XILUTION_AWS_REGION" \
      -var="xilution_environment=$XILUTION_ENVIRONMENT" \
      -var="xilution_pipeline_type=$PIPELINE_TYPE" \
      -auto-approve \
      "${terraformModuleDir}"

  elif [[ "${direction}" == "down" ]]; then

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
      "${terraformModuleDir}"

  fi

else
  echo "terraformModuleDir not found."
fi

cd "${currentDir}" || false

echo "All Done!"
