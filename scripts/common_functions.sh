#!/bin/bash -e

wait_for_site_to_be_ready() {

  [ -z "$1" ] && echo "The first argument should be the url." && exit 1
  [ -z "$CODEBUILD_BUILD_ID" ] && echo "Didn't find CODEBUILD_BUILD_ID env var." && exit 1

  url=${1}
  count=0
  sleepSeconds=5
  maxAttempts=60

  echo "url = ${url}"

  while [[ $(curl -s -o /dev/null -w '%{http_code}' "${url}") != "200" && "${count}" -lt "${maxAttempts}" ]]; do
    sleep ${sleepSeconds}
    echo "site not ready yet..."
    count=$((count + 1))
  done

  if [[ "${count}" == "${maxAttempts}" ]]; then
    aws codebuild stop-build --id "${CODEBUILD_BUILD_ID}"
  fi
}

execute_commands() {

  [ -z "$1" ] && echo "The first argument should be commands." && exit 1

  commands=${1}

  for command in ${commands}; do
    echo "${command}" | base64 --decode | bash
  done
}
