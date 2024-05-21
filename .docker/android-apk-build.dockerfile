FROM ubuntu:latest as build 

RUN apt update && apt upgrade -y && apt install -y python3 python3-pip git curl nodejs  && \
    mkdir -p /home/mobiledevops && \
    git clone https://github.com/KomodoPlatform/komodo-wallet-mobile /home/mobiledevops/komodo-wallet-mobile && \ 
    cd /home/mobiledevops/komodo-wallet-mobile && \
    curl -o assets/coins.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/coins && \
    curl -o assets/coins_config.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/utils/coins_config.json && \
    mkdir -p android/app/src/main/cpp/libs/armeabi-v7a && \
    mkdir -p android/app/src/main/cpp/libs/arm64-v8a

FROM mobiledevops/android-sdk-image:34.0.0-jdk17 as final

ENV FLUTTER_VERSION="2.8.1"
ENV FLUTTER_HOME "/home/mobiledevops/.flutter-sdk"
ENV USER="mobiledevops"
ENV PATH $PATH:$FLUTTER_HOME/bin

# Download and extract Flutter SDK
RUN mkdir $FLUTTER_HOME \
    && cd $FLUTTER_HOME \
    && curl --fail --remote-time --silent --location -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz --strip-components=1 \
    && rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

ENV ANDROID_HOME "/opt/android-sdk-linux"
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools

RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update && \
    sdkmanager --install "cmdline-tools;latest" --sdk_root=${ANDROID_SDK_ROOT} && \
    sdkmanager --install "platform-tools" --sdk_root=${ANDROID_SDK_ROOT}    

RUN flutter config --no-analytics --android-sdk=$ANDROID_HOME \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter update-packages \
    && dart .docker/update_api.dart

COPY --from=build /home/mobiledevops/komodo-wallet-mobile /home/mobiledevops/komodo-wallet-mobile

WORKDIR /home/$USER/komodo-wallet-mobile

CMD [ "flutter", "build", "apk", "--release" ]