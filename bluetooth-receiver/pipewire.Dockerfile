# https://walkergriggs.com/2022/12/03/pipewire_in_docker/
# https://github.com/PipeWire/pipewire/blob/master/INSTALL.md
FROM ubuntu:22.04 AS build
RUN apt-get update \
    && apt-get install -y \
    debhelper-compat \
    findutils \
    git \
#    libapparmor-dev \
    libasound2-dev \
    libavcodec-dev \
    libavfilter-dev \
    libavformat-dev \
    libbluetooth-dev \
    libdbus-1-dev \
    libldacbt-abr-dev \
    libldacbt-enc-dev  \
    libglib2.0-dev \
#    libgstreamer1.0-dev \
#    libgstreamer-plugins-base1.0-dev \
    libreadline-dev \
    libsbc-dev \
    libsdl2-dev \
#    libsnapd-glib-dev \
    libudev-dev \
#    libva-dev \
#    libv4l-dev \
#    libx11-dev \
    meson \
    ninja-build \
    pkg-config \
    python3-docutils
#    python3-pip \
#    pulseaudio \
#    dbus-x11 \
#    rtkit \
#    xvfb

ARG PW_VERSION="1.0.3"
ENV PW_ARCHIVE_URL="https://github.com/PipeWire/pipewire/archive/refs/tags"
ENV PW_TAR_FILE="${PW_VERSION}.tar.gz"
ENV PW_TAR_URL="${PW_ARCHIVE_URL}/${PW_TAR_FILE}"
ENV BUILD_DIR_BASE="/root"
ENV BUILD_DIR="${BUILD_DIR_BASE}/build-$PW_VERSION"
ENV MESON_OPTIONS=" \
    -Dalsa=enabled \
    -Dbluez5=enabled \
    -Dgstreamer=disabled  \
    -Dlegacy-rtkit=false \
    -Dreadline=enabled \
    -Dsystemd=disabled \
    -Dx11=disabled"

RUN curl -LJO $PW_TAR_URL \
    && tar -C $BUILD_DIR_BASE -xvf pipewire-$PW_TAR_FILE
RUN cd $BUILD_DIR_BASE/pipewire-${PW_VERSION} \
    && meson setup $BUILD_DIR $MESON_OPTIONS -Dprefix=/usr/local \
    && meson compile -C $BUILD_DIR \
    && meson install -C $BUILD_DIR

#FROM ubuntu:22.04
#COPY --from=build /usr/local /usr/local
WORKDIR /root
ENV PIPEWIRE_RUNTIME_DIR="/tmp"
ENV PIPEWIRE_DEBUG="3"
COPY pipewire-entrypoint.sh entrypoint.sh
#CMD ["/bin/bash", "entrypoint.sh"]
