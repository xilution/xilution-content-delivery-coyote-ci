#!/bin/bash -e

[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1

pipelineId=${PIPELINE_ID}
stageName=${STAGE_NAME}

pipelineIdShort=$(echo "${pipelineId}" | cut -c1-8)
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
bucket="s3://xilution-coyote-${pipelineIdShort}-${stageNameLower}-web-content"
aws s3 rm "${bucket}" --recursive --include "*"

echo "All Done!"
