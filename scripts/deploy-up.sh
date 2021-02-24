#!/bin/bash -e

[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$COMMIT_ID" ] && echo "Didn't find COMMIT_ID env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1

pipelineId=${PIPELINE_ID}
sourceVersion=${COMMIT_ID}
stageName=${STAGE_NAME}
pipelineIdShort=$(echo "${pipelineId}" | cut -c1-8)
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

sourceBucket="s3://xilution-coyote-${pipelineIdShort}-source-code/"
webContentZipFileName="${sourceVersion}-${stageNameLower}-web-content.zip"

aws s3 cp "${sourceBucket}${webContentZipFileName}" .

mkdir -p ./temp
mv ./${webContentZipFileName} ./temp
cd ./temp || false
unzip ./${webContentZipFileName}
rm -rf ./${webContentZipFileName}

webContentBucket="s3://xilution-coyote-${pipelineIdShort}-${stageNameLower}-web-content"
aws s3 cp . "${webContentBucket}" --recursive --include "*" --acl public-read

cd ../
rm -rf ./temp

echo "All Done!"
