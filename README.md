[![Build Status](https://app.bitrise.io/app/bc464ad88d40bb68/status.svg?token=tnpzqFp_7vrcsQYqWSIVBQ&branch=dev)](https://app.bitrise.io/app/bc464ad88d40bb68)  
# atomicDEX v0.4.1
Komodo Platform's hybrid mutlicoin DEX-wallet. 

## Getting Started

Build requires up-to-date version of coins file from https://github.com/KomodoPlatform/coins

Commit hash and sah256sum of coins file is specified in `coins_ci.json`.
You may download one manually or use `fetch_coins.sh` script on linux and macOS,
 `fetch_coins.ps1` powershell script on Windows.

`fetch_coins` script depends on sha256sum and jq utils:

Ubuntu: `sudo apt-get update && sudo apt-get install -y coreutils jq`

MacOS: `brew install coreutils jq`, [Brew software](https://brew.sh/)

Windows: `choco install jq`, [Choco sowftware](https://chocolatey.org/)


## For iOS build:

Do

    (cd ios && rm -rf Podfile.lock Podfile Pods)

between flutter upgrades.
cf. https://github.com/flutter/flutter/issues/39507#issuecomment-565849075

## For Android build:


## Flutter version

Currently using flutter 1.22.4 in order to enjoy some recent UI fixes/updates, ref: https://github.com/ca333/komodoDEX/issues/913

Upgrading from v1.12.13+hotfix.7

    flutter channel stable
    flutter version v1.22.4
    flutter pub get
    flutter clean
    (cd ios && rm -rf Podfile.lock Podfile Pods)

(If the "flutter version" doesn't have the required version in the list yet then one way to get it is to go to the flutter directory (cf. `which flutter`) and invoke `git pull` there).

### beta Flutter

`flutter version` is inconsistent regarding the access to beta versions.
Git tags can be used instead (that is, when we want to experiment with beta versions of Flutter):

    FD=`which flutter`; FD=`dirname $FD`; FD=`dirname $FD`; echo $FD; cd $FD
    git pull
    git reset --hard
    git checkout -f v1.14.3

### Kotlin vs Flutter

In Android Studio (3.6.2) the latest Kotlin plugin (1.3.71) doesn't work with Flutter “1.12.13+hotfix.7”. To fix it - [uninstall the latest Kotlin](https://github.com/flutter/flutter/issues/52077#issuecomment-600459786) - then the Kotlin version 1.3.61, bundled with the Android Studio, will reappear.

## Accessing the database

    adb exec-out run-as com.komodoplatform.atomicdex cat /data/data/com.komodoplatform.atomicdex/app_flutter/AtomicDEX.db > AtomicDEX.db
    sqlite3 AtomicDEX.db

## Audio samples sources

 - [ticking sound](https://freesound.org/people/FoolBoyMedia/sounds/264498/)
 - [silence](https://freesound.org/people/Mullabfuhr/sounds/540483/)
 - [start (iOs)](https://freesound.org/people/pizzaiolo/sounds/320664/)
