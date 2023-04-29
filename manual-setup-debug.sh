#!/usr/bin/env bash

# Install git
sudo apt update
sudo apt install git -y

# Install docker
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg -y

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Clone and prepare pi-gen
git clone https://github.com/RPi-Distro/pi-gen.git
touch ./pi-gen/stage2/SKIP_IMAGES ./pi-gen/stage2/SKIP_NOOBS

# Move files
cp ./pigen_config ./pi-gen/pigen_config
mkdir -p ./stage2-sonos-streaming/00-build-services/files/
cp -r ./darkice ./stage2-sonos-streaming/00-build-services/files/
cp -r ./icecast ./stage2-sonos-streaming/00-build-services/files/
cp ./docker-compose.yml ./stage2-sonos-streaming/00-build-services/files/

mkdir -p ./stage2-sonos-streaming/01-setup-startup/files/
cp ./sonos-streaming.service ./stage2-sonos-streaming/01-setup-startup/files/

cp -r ./stage2-sonos-streaming ./pi-gen/
