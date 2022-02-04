#!/bin/bash

# To Test:
#  * Grab the latest version-manifest.json
#  * place the file where this script can read it
#  * execute the script
#  * Output should look similar to: `gitlab_version_info{component="gitlab-pages",version="v1.5.0",sha="869b94c86f7a4eb74b99c0eb6cad92e1d994d1b4"} 1.0`

set -e

declare -a metrics=$(jq -r '.software | to_entries[] | select(.value.locked_source.git) | select(.value.locked_source.git | test("git@dev.gitlab.org:gitlab")) | [.key, .value.described_version, .value.locked_version] | @csv' /opt/gitlab/version-manifest.json)

for i in ${metrics[@]}; do
  component=$(echo $i | cut -d, -f1)
  version=$(echo $i | cut -d, -f2)
  sha=$(echo $i | cut -d, -f3)
  echo "gitlab_version_info{component=${component},version=${version},sha=${sha}} 1.0"
done
