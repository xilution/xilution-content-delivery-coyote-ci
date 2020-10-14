#!/bin/bash -ex

. ./scripts/common_functions.sh

stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

currentDir=$(pwd)
cd "${sourceDir}" || false

commands=$(jq -r ".builds.${stageName}.commands[] | @base64" <./xilution.json)
execute_commands "${commands}"

buildDir=$(jq -r ".builds.buildDir" <./xilution.json)

if [[ "${buildDir}" == "null" ]]; then
  echo "Unable to find build directory."
  exit 1
fi

cd "${buildDir}" || false

zip -r ../build.zip .
mv ../build.zip "${currentDir}"

cd "${currentDir}" || false
