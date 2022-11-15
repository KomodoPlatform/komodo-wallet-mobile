$config_init_mm2 = "assets\coins.json"

# back compatibility
if ( ( Test-Path -Path $config_init_mm2 -PathType Leaf ) -and -not ( Test-Path -Path "coins_ci.json" -PathType Leaf ) ) {
    exit
    }

# get coins file
$coins_repo_commit = $( jq.exe -r '.coins_repo_commit' .\coins_ci.json)
curl.exe -l "https://raw.githubusercontent.com/KomodoPlatform/coins/${coins_repo_commit}/coins" --output $config_init_mm2

# clean checks from previous run
rm .\app_assets
rm .\coins_assets

# get assets lists
jq.exe -r 'keys | .[]' "assets/coins_config.json" > app_assets
jq.exe -r '.[].coin' $config_init_mm2 > coins_assets

# check if all assets from coins_config are present in coins.json
foreach( $line in Get-Content ".\app_assets" ) {
    if ( ( Get-Content ".\coins_assets" ).contains( $line ) ) {
        echo "$line check passed"
        }
    else  {
        throw "Asset $line not found in coins file"
        }
    }
