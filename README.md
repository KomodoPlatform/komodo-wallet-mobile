# atomicDEX v0.1

Komodo Platform's hybrid mutlicoin DEX-wallet. 

## Getting Started


## For iOS build:

Do

    (cd ios && rm -rf Podfile.lock Podfile Pods)

between flutter upgrades.
cf. https://github.com/flutter/flutter/issues/39507#issuecomment-565849075

## For Android build:


## Flutter version

Currently using flutter 1.12.13+hotfix.7 in order to enjoy some recent UI fixes/updates, cf. https://github.com/ca333/komodoDEX/pull/656/commits/010c276b3aec9cb2231527ef18e9c2969c47f3ce

Upgrading from v1.9.1+hotfix.6  

    flutter version 1.12.13+hotfix.7
    flutter clean
    (cd ios && rm -rf Podfile.lock Podfile Pods)
    flutter packages upgrade

(If the "flutter version" doesn't have the required version in the list yet then one way to get it is to go to the flutter directory (cf. `which flutter`) and invoke `git pull` there).

### beta Flutter

`flutter version` is inconsistent regarding the access to beta versions.
Git tags can be used instead (that is, when we want to experiment with beta versions of Flutter):

    FD=`which flutter`
    FD=`dirname $FD`
    FD=`dirname $FD`
    echo $FD
    cd $FD
    git pull
    git reset --hard
    git checkout -f v1.14.3
