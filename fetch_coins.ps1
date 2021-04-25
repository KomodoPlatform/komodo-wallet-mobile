$config_init_mm2 = "assets\coins_init_mm2.json"

# back compatibility
if ( ( Test-Path -Path $config_init_mm2 -PathType Leaf )  -and -not ( Test-Path -Path "coins_ci.json" -PathType Leaf ) ) {
    exit
    }

# get coins file
$comm = $( jq.exe -r .commit .\coins_ci.json)
$sha_expected = $( jq.exe -r .sha256 .\coins_ci.json)
curl.exe -l "https://raw.githubusercontent.com/KomodoPlatform/coins/${comm}/coins" --output $config_init_mm2

# validate coins file
if ( -not $( ( Get-FileHash $config_init_mm2 ).Hash -eq $sha_expected ) ) {
    throw "Unexpected coins file shasum"
    }

# clean checks from previous run
rm .\app_assets
rm .\coins_assets

# get assets lists
jq.exe -r '.[].abbr' "assets/coins_config.json" > app_assets
jq.exe -r '.[].coin' $config_init_mm2 > coins_assets

# check if all assets from coins_config are present in coins_init_mm2
foreach( $line in Get-Content ".\app_assets" ) {
    if ( ( Get-Content ".\coins_assets" ).contains( $line ) ) {
        echo "$line check passed"
        }
    else  {
        throw "Asset $line not found in coins file"
        }
    }
