# atomicDEX v0.1

Komodo Platform's hybrid mutlicoin DEX-wallet. 

## Getting Started


## For iOS build:


## For Android build:


## Flutter version

Currently using flutter v1.14.3 in order to enjoy some recent UI fixes/updates, cf. https://github.com/ca333/komodoDEX/pull/656/commits/010c276b3aec9cb2231527ef18e9c2969c47f3ce

Upgrading from v1.9.1+hotfix.6  
(NB: `flutter version` doesn't work with `1.14.3` yet)  

    FD=`which flutter`
    FD=`dirname $FD`
    FD=`dirname $FD`
    echo $FD
    cd $FD
    git pull
    git reset --hard
    git checkout -f v1.14.3

    cd .../komodoDEX/
    flutter packages upgrade
    flutter clean
