#!/bin/bash -ex

pipelineId=${COYOTE_PIPELINE_ID}
stageName=${STAGE_NAME}
awsRegion=${CLIENT_AWS_REGION}

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
site_base_url="http://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content.s3-website-${awsRegion}.amazonaws.com"

export SITE_BASE_URL=${site_base_url}
