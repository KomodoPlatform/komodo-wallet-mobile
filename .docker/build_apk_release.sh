set -e

docker build -f .docker/kdf-android-build.dockerfile . -t komodo/kdf-android --build-arg KDF_BRANCH=main
docker build -f .docker/android-sdk.dockerfile . -t komodo/android-sdk:34
docker build -f .docker/android-apk-build.dockerfile . -t komodo/komodo-wallet-mobile
docker run --rm -v ./build:/app/build komodo/komodo-wallet-mobile:latest flutter build apk --release