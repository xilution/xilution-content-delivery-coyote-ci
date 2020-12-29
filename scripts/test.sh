#!/bin/bash -e

[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1
[ -z "$BASE_URL" ] && echo "Didn't find BASE_URL env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

. ./scripts/common_functions.sh

stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
baseUrl=${BASE_URL}

wait_for_site_to_be_ready "${baseUrl}"

cd "${sourceDir}" || false

testDetails=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".tests.${stageName}[] | @base64")

for testDetail in ${testDetails}; do
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done

cd "${currentDir}" || false

echo "All Done!"
