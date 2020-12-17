#!/bin/bash -ex

buildOutputDir=${CODEBUILD_SRC_DIR_BuildOutput}
pipelineId=${COYOTE_PIPELINE_ID}
sourceVersion=${COMMIT_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

sourceCodeBucket="s3://xilution-coyote-${pipelineId:0:8}-source-code/"
webContentZipFileName="${sourceVersion}-${stageNameLower}-web-content.zip"

aws s3 cp "${sourceCodeBucket}${webContentZipFileName}" .

mkdir -p ./temp
mv ./${webContentZipFileName} ./temp
cd ./temp || false
unzip ./${webContentZipFileName}
rm -rf ./${webContentZipFileName}

webContentBucket="s3://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content"
aws s3 cp . "${webContentBucket}" --recursive --include "*" --acl public-read

echo "All Done!"
