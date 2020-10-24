#!/bin/bash -ex

. ./scripts/common_functions.sh

pipelineId=${COYOTE_PIPELINE_ID}
stageName=${STAGE_NAME}
awsRegion=${CLIENT_AWS_REGION}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
siteUrl="http://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content.s3-website-${awsRegion}.amazonaws.com"

wait_for_site_to_be_ready "${siteUrl}"

currentDir=$(pwd)
cd "${sourceDir}" || false

testDetails=$(jq -r ".tests.${stageName}[] | @base64" <./xilution.json)

for testDetail in ${testDetails}; do
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done

cd "${currentDir}" || false
