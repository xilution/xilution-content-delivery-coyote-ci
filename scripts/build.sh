#!/bin/bash -e

[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1
[ -z "$COMMIT_ID" ] && echo "Didn't find COMMIT_ID env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

. ./scripts/common-functions.sh

pipelineId=${PIPELINE_ID}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
sourceVersion=${COMMIT_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

echo "pipelineId = ${pipelineId}"
echo "sourceDir = ${sourceDir}"
echo "sourceVersion = ${sourceVersion}"

commands=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".build.commands[] | @base64")
execute_commands "${commands}"

cd "${sourceDir}" || false

buildDir=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".build.buildDir")
if [[ "${buildDir}" == "null" ]]; then
  echo "Unable to find build directory."
  exit 1
fi

cd "${sourceDir}/${buildDir}" || false
webContentZipFileName="${sourceVersion}-${stageNameLower}-web-content.zip"
zip -r "${sourceDir}/${webContentZipFileName}" .

cd "${sourceDir}" || false
pipelineIdShort=$(echo "${pipelineId}" | cut -c1-8)
sourceCodeBucket="s3://xilution-coyote-${pipelineIdShort}-source-code/"
aws s3 cp "./${webContentZipFileName}" "${sourceCodeBucket}"

cd "${currentDir}" || false

echo "All Done!"
