FROM debian:bookworm
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bluetooth bluez-tools bluez-alsa-utils \
    vim usbutils
COPY bluetooth-main.conf /etc/bluetooth/main.conf
COPY machine-info /etc/
COPY entrypoint.sh /
ENTRYPOINT [ "/bin/bash" ]
