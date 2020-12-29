#!/bin/bash -e

[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1

pipelineId=${PIPELINE_ID}
stageName=${STAGE_NAME}
awsRegion=${CLIENT_AWS_REGION}

echo "pipelineId = ${pipelineId}"
echo "stageName = ${stageName}"
echo "awsRegion = ${awsRegion}"

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
pipelineIdShort=$(echo "${pipelineId}" | cut -c1-8)

echo "stageNameLower = ${stageNameLower}"
echo "pipelineIdShort = ${pipelineIdShort}"

base_url="http://xilution-coyote-${pipelineIdShort}-${stageNameLower}-web-content.s3-website-${awsRegion}.amazonaws.com"

export BASE_URL=${base_url}
