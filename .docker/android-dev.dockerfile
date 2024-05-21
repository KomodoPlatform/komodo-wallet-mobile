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
    chown -R $USER:$USER /home/$USER

USER $USER

# Download and extract Flutter SDK
RUN mkdir -p /home/komodo/workspace \
    && chown -R $USER:$USER /home/komodo/workspace \
    && mkdir -p $FLUTTER_HOME \
    && cd $FLUTTER_HOME \
    && curl --fail --remote-time --silent --location -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz --strip-components=1 \
    && rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    && flutter config --no-analytics  \
    && flutter precache \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter update-packages 
