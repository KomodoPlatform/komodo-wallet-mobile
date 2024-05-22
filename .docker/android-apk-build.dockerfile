FROM ubuntu:24.04 as build 

ENV FLUTTER_HOME "/home/komodo/.flutter-sdk"

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
    .venv/bin/python .docker/update_api.py --force && \
    git clone https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    git fetch && \
    git checkout tags/2.8.1 

# Locally tagged image for now
FROM komodo/android-sdk:34 as final

ENV FLUTTER_VERSION="2.8.1"
ENV FLUTTER_HOME "/home/komodo/.flutter-sdk"
ENV USER="komodo"
ENV PATH $PATH:$FLUTTER_HOME/bin

COPY --from=build --chown=$USER:$USER ${FLUTTER_HOME} ${FLUTTER_HOME}

RUN flutter config --no-analytics  \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter update-packages 

COPY --from=build /app /app

WORKDIR /app

CMD [ "flutter", "build", "apk", "--release" ]
