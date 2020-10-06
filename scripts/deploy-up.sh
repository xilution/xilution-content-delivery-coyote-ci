#!/bin/bash

buildOutputDir=${1}
pipelineId=${2}
stageName=${3}

cd "${buildOutputDir}" || exit
mkdir ./temp
mv ./artifacts.zip ./temp
cd ./temp || exit
unzip artifacts.zip
rm -rf artifacts.zip
unzip dist.zip
rm -rf dist.zip
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
bucket="s3://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content"
aws s3 cp . "${bucket}" --recursive --include "*" --acl public-read
