FROM debian:bookworm
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y liquidsoap alsa-utils vim
WORKDIR /
COPY streaming.liq .
# ENTRYPOINT ["/usr/bin/liquidsoap", "streaming.liq"]
ENTRYPOINT ["sleep", "3600"]
