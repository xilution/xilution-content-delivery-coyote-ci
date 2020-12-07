#!/bin/bash -ex

pipelineId=${COYOTE_PIPELINE_ID}
stageName=${STAGE_NAME}

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
bucket="s3://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content"
aws s3 rm "${bucket}" --recursive --include "*"

echo "All Done!"
