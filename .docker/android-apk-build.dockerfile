FROM --platform=linux/amd64 ubuntu:latest as build 

RUN apt update && \ 
    apt upgrade -y && \ 
    apt install -y python3 python3-pip git curl nodejs python3-venv && \
    mkdir -p /app

WORKDIR /app

COPY . .

# TODO: add .gitkeep files for the missing directories 
RUN curl -o assets/coins.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/coins && \
    curl -o assets/coins_config.json https://raw.githubusercontent.com/KomodoPlatform/coins/master/utils/coins_config.json && \
    mkdir -p android/app/src/main/cpp/libs/armeabi-v7a && \
    mkdir -p android/app/src/main/cpp/libs/arm64-v8a && \
    python3 -m venv .venv && \ 
    .venv/bin/pip install -r .docker/requirements.txt && \
    .venv/bin/python .docker/update_api.py --force

FROM --platform=linux/amd64 ghcr.io/cirruslabs/android-sdk:34 as final

ENV FLUTTER_VERSION="2.8.1"
ENV FLUTTER_HOME "/home/komodo/.flutter-sdk"
ENV USER="komodo"
ENV PATH $PATH:$FLUTTER_HOME/bin

# Download and extract Flutter SDK
RUN mkdir -p $FLUTTER_HOME \
    && git config --global --add safe.directory /home/komodo/.flutter-sdk \
    && cd $FLUTTER_HOME \
    && curl --fail --remote-time --silent --location -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz --strip-components=1 \
    && rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

RUN flutter config --no-analytics  \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter update-packages 

COPY --from=build /app /app

WORKDIR /app

CMD [ "flutter", "build", "apk", "--release" ]
