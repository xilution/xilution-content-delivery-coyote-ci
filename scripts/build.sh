#!/bin/bash -ex

. ./scripts/common_functions.sh

pipelineId=${COYOTE_PIPELINE_ID}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
sourceVersion=${COMMIT_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

echo "pipelineId = ${pipelineId}"
echo "sourceDir = ${sourceDir}"
echo "sourceVersion = ${sourceVersion}"

cd "${sourceDir}" || false

buildDir=$(jq -r ".build.buildDir" <./xilution.json)
if [[ "${buildDir}" == "null" ]]; then
  echo "Unable to find build directory."
  exit 1
fi

commands=$(jq -r ".build.commands[] | @base64" <./xilution.json)
execute_commands "${commands}"

sourceCodeBucket="s3://xilution-coyote-${pipelineId:0:8}-source-code/"
webContentZipFileName="${sourceVersion}-${stageNameLower}-web-content.zip"

cd "${buildDir}" || false
zip -r "${sourceDir}/${webContentZipFileName}" .
cd "${sourceDir}" || false

aws s3 cp "./${webContentZipFileName}" "${sourceCodeBucket}"

echo "All Done!"
