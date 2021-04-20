#!/bin/bash
set -e
set -x

# back compatibility
if [[ -f "assets/coins_init_mm2.json" && ! -f "coins_ci.json" ]]; then
    exit 0
fi

# get coins file
comm="$(cat coins_ci.json | jq -r .commit)"
sha_expected="$(cat coins_ci.json | jq -r .sha256)"
curl -l "https://raw.githubusercontent.com/KomodoPlatform/coins/${comm}/coins" --output "assets/coins_init_mm2.json"

# validate coins file
echo "${sha_expected} assets/coins_init_mm2.json" | sha256sum --check --strict

# get assets lists
cat assets/coins_config.json | jq -r '.[].abbr' > app_assets
cat assets/coins_init_mm2.json | jq -r '.[].coin' > coins_assets

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
