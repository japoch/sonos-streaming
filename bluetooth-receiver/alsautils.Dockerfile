FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    bluetooth \
    bluez-tools \
    bluez-alsa-utils \
    rfkill \
    usbutils \
    vim \
    && rm -rf /var/lib/apt/lists/*
COPY bluetooth-main.conf /etc/bluetooth/main.conf
WORKDIR /
COPY alsautils-entrypoint.sh entrypoint.sh
ENTRYPOINT ["/bin/bash"]
