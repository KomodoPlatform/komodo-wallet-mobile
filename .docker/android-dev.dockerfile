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
    && flutter update-packages 
