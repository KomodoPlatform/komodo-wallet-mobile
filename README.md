# atomicDEX v0.1

Komodo Platform's hybrid mutlicoin DEX-wallet. 

## Getting Started


## For iOS build:


## For Android build:


## Flutter version

Stable v1.12.13+hotfix.5 fails currently with

    Running Gradle task 'assembleRelease'...
    /Users/administrator/Desktop/komodoDEX-dev/build/flutter_sodium/intermediates/res/merged/release/values/values.xml:236: error: resource android:attr/fontVariationSettings not found.

Should use Flutter v1.9.1+hotfix.6 (the previous stable) until this issue is resolved.

    flutter version v1.9.1+hotfix.6
    flutter clean
    (cd ios && rm -rf Podfile.lock Podfile Pods)

can be used to downgrade.
