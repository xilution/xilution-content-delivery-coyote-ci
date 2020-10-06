#!/bin/bash

. ./scripts/common_functions.sh

stageName=${1}
sourceDir=${2}

currentDir=$(pwd)
cd "${sourceDir}" || false

commands=$(jq -r ".build.${stageName}.commands[] | @base64" <./xilution.json)
execute_commands "$commands"
distDir=$(jq -r ".build.distDir" <./xilution.json)
cd "${distDir}" || exit
zip -r ../dist.zip .
mv ../dist.zip "${currentDir}"
