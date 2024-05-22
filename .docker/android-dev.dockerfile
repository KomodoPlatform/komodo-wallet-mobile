FROM --platform=linux/amd64 ghcr.io/cirruslabs/android-sdk:34 as final

ENV FLUTTER_VERSION="2.8.1"
ENV FLUTTER_HOME "/home/komodo/.flutter-sdk"
ENV USER="komodo"
ENV PATH $PATH:$FLUTTER_HOME/bin

RUN apt update && apt install -y python3 python3-pip python3-venv && \
    python3 -m venv /home/komodo/.venv && \
    useradd -u 1001 -m $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown -R $USER:$USER /home/$USER && \
    chown -R $USER:$USER /opt/android-sdk-linux && \
    chmod -R u+rw,g+rw /opt/android-sdk-linux 

USER $USER

# Download and extract Flutter SDK
RUN mkdir -p /home/komodo/workspace \
    && chown -R $USER:$USER /home/komodo/workspace \
    && git clone https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && cd ${FLUTTER_HOME} \
    && git fetch \
    && git checkout tags/2.8.1 \
    && flutter config --no-analytics  \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter update-packages 
