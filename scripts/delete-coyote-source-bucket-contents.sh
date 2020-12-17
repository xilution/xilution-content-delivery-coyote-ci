#!/bin/bash -ex

pipelineId=${COYOTE_PIPELINE_ID}

aws s3 rm "s3://xilution-coyote-${pipelineId:0:8}-source-code" --include "*" --recursive

echo "All Done!"
