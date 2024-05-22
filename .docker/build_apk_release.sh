docker build -f .docker/android-sdk.dockerfile . -t komodo/android-sdk:34
docker build -f .docker/android-apk-build.dockerfile . -t komodo/komodo-wallet-mobile
docker run --rm -v ./build:/app/build komodo/komodo-wallet-mobile:latest