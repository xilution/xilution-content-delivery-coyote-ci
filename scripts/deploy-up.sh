#!/bin/bash -ex

buildOutputDir=${CODEBUILD_SRC_DIR_BuildOutput}
pipelineId=${COYOTE_PIPELINE_ID}
stageName=${STAGE_NAME}

cd "${buildOutputDir}" || false
ls
mkdir ./temp
mv ./artifacts.zip ./temp
cd ./temp || false
unzip artifacts.zip
rm -rf artifacts.zip
unzip build.zip
rm -rf build.zip
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
bucket="s3://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content"
aws s3 cp . "${bucket}" --recursive --include "*" --acl public-read
