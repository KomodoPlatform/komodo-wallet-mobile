#!/bin/bash
set -e
set -x

# back compatibility
if [[ -f "assets/coins_init_mm2.json" && ! -f "coins_ci.json" ]]; then
    exit 0
fi

# get coins file
coins_repo_commit="$( jq -r '.coins_repo_commit' coins_ci.json )"
curl -l "https://raw.githubusercontent.com/KomodoPlatform/coins/${coins_repo_commit}/coins" --output "assets/coins_init_mm2.json"

# get assets lists
jq 'keys | .[]' assets/0.5.6-coins.json > app_assets
jq -r '.[].coin' assets/coins_init_mm2.json > coins_assets

# check if all assets from coins_config are present in coins_init_mm2
set +x
while IFS= read -r line;  do
    if [[ "${line}" =~ $(echo ^\($(paste -sd'|' coins_assets)\)$) ]]; then
        echo "${line} check passed"
    else
        echo "${line} not found"
        exit 2
    fi
done < app_assets
