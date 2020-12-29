#!/bin/bash -e

[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1
[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1

. ./scripts/common-functions.sh

stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
xilutionConfig=${XILUTION_CONFIG}
pipelineId=${PIPELINE_ID}
awsRegion=${CLIENT_AWS_REGION}
pipelineType=${PIPELINE_TYPE}

echo "stageName = ${stageName}"
echo "sourceDir = ${sourceDir}"
echo "currentDir = ${currentDir}"
echo "xilutionConfig = ${xilutionConfig}"
echo "pipelineId = ${pipelineId}"
echo "awsRegion = ${awsRegion}"
echo "pipelineType = ${pipelineType}"

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
pipelineIdShort=$(echo "${pipelineId}" | cut -c1-8)

echo "stageNameLower = ${stageNameLower}"
echo "pipelineIdShort = ${pipelineIdShort}"

if [[ "${pipelineType}" == "AWS_SMALL" ]]; then
  baseUrl="http://xilution-coyote-${pipelineIdShort}-${stageNameLower}-web-content.s3-website-${awsRegion}.amazonaws.com"
elif [[ "${pipelineType}" == "AWS_MEDIUM" ]]; then
  baseUrl=$(aws cloudfront list-distributions | jq -r ".DistributionList.Items[] | select(.Comment == \"xilution-coyote-${pipelineIdShort}-${stageNameLower}-web-content\") | .DomainName")
else
  echo "Unrecognized pipeline type: ${pipelineType}"
  exit 1
fi

echo "baseUrl = ${baseUrl}"

wait_for_site_to_be_ready "${baseUrl}"

cd "${sourceDir}" || false

testDetails=$(echo "${xilutionConfig}" | base64 --decode | jq -r ".tests.${stageName}[] | @base64")

for testDetail in ${testDetails}; do
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done

cd "${currentDir}" || false

echo "All Done!"
