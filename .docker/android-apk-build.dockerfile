FROM komodo/kdf-android:latest as build 

RUN cd /app && \ 
    rustup default nightly-2022-10-29 && \
    rustup target add aarch64-linux-android && \
    rustup target add armv7-linux-androideabi && \
    export PATH=$PATH:/android-ndk/bin && \
    CC_aarch64_linux_android=aarch64-linux-android21-clang CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=aarch64-linux-android21-clang cargo rustc --target=aarch64-linux-android --lib --release --crate-type=staticlib --package mm2_bin_lib && \
    CC_armv7_linux_androideabi=armv7a-linux-androideabi21-clang CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=armv7a-linux-androideabi21-clang cargo rustc --target=armv7-linux-androideabi --lib --release --crate-type=staticlib --package mm2_bin_lib && \
    mv target/aarch64-linux-android/release/libmm2lib.a target/aarch64-linux-android/release/libmm2.a &&\
    mv target/armv7-linux-androideabi/release/libmm2lib.a target/armv7-linux-androideabi/release/libmm2.a

FROM komodo/android-sdk:34 as final

ENV FLUTTER_VERSION="2.8.1"
ENV FLUTTER_HOME "/home/komodo/.flutter-sdk"
ENV USER="komodo"
ENV PATH $PATH:$FLUTTER_HOME/bin
ENV ANDROID_AARCH64_LIB=android/app/src/main/cpp/libs/arm64-v8a
ENV ANDROID_AARCH64_LIB_SRC=/app/target/aarch64-linux-android/release/libmm2.a
ENV ANDROID_ARMV7_LIB=android/app/src/main/cpp/libs/armeabi-v7a
ENV ANDROID_ARMV7_LIB_SRC=/app/target/armv7-linux-androideabi/release/libmm2.a

WORKDIR /app
COPY . .

RUN curl -o assets/coins.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/coins && \
    curl -o assets/coins_config.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/utils/coins_config.json && \
    mkdir -p android/app/src/main/cpp/libs/armeabi-v7a && \
    mkdir -p android/app/src/main/cpp/libs/arm64-v8a && \
    git clone https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    git fetch && \
    git checkout tags/2.8.1 

COPY --from=build --chown=$USER:$USER ${ANDROID_AARCH64_LIB_SRC} ${ANDROID_AARCH64_LIB}
COPY --from=build --chown=$USER:$USER ${ANDROID_ARMV7_LIB_SRC} ${ANDROID_ARMV7_LIB}

RUN flutter config --no-analytics  \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter update-packages 
