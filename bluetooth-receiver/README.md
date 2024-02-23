# Bluetooth Receiver

## Running on Raspberry PI 2B Debian 11 "Bullseye"

**!DEPRECATED!**

### Sources

- [Github - Raspberry Pi Audio Receiver](https://github.com/nicokaiser/rpi-audio-receiver)
- [Stackoverflow - Accessing Bluetooth dongle from inside Docker?](https://stackoverflow.com/questions/28868393/accessing-bluetooth-dongle-from-inside-docker)
- [Github - Bluetooth audio on a headless Raspberry Pi using BlueAlsa](https://introt.github.io/docs/raspberrypi/bluealsa.html)
- [Sigmdel - Bluetooth®, PulseAudio, and BlueALSA in Raspberry Pi OS Lite (March 2022)](https://www.sigmdel.ca/michel/ha/rpi/bluetooth_in_rpios_02_en.html#bluealsa3)

### Get it running

```bash
# fresh install Bluetooth
# https://return2.net/fix-bluetooth-problems-on-raspberry-pi-running-raspbian/
sudo apt-get purge -y bluez bluez-firmware pi-bluetooth && sudo apt-get install pi-bluetooth
/usr/bin/bluetoothctl discoverable on
/usr/bin/bluetoothctl show
# installing BlueAlsa (working till Raspian 11 bullseye)
sudo echo "deb http://archive.raspberrypi.org/debian/ buster main" | sudo tee /etc/apt/sources.list.d/raspi-buster.list
sudo printf 'Package: *\nPin: release n=buster\nPin-Priority: 50\n' | sudo tee --append /etc/apt/preferences.d/limit-buster
sudo apt-get update && apt-cache policy bluealsa
sudo apt-get install -y --no-install-recommends bluealsa
sudo systemctl start bluealsa
```

## Running on Raspberry PI 2B Debian 11 "Bullseye" with PipeWire and WirePlumber

Operating system Raspberry Pi OS (Legacy) Lite, System: 32-bit, Kernel version: 6.1, Debian version: 11 (bullseye).

PipeWire is able to output sound to the internal audio chipset without any special configuration. It provides Bluetooth® A2DP support with optional codecs (SBC-XQ, LDAC, aptX, aptX HD, aptX-LL, FastStream) out of the box.

At the same time, WirePlumber automatically creates the connection between the A2DP source and the audio chipset when a remote device, like a phone or a laptop, connects. This makes the configuration very easy, as PipeWire will work out of the box. We will only need to set up BlueZ to make the system headless.

Client > Bluetooth > WirePlumber > PipeWire > ALSA > Kernel

### Sources

- [PC-Welt - Wie Sie den Raspberry Pi als “Bluetooth-Adapter” nutzen](https://www.pcwelt.de/article/1397754/wie-sie-den-raspberry-pi-als-bluetooth-adapter-nutzen.html)
- [Collabora - Using a Raspberry Pi as a Bluetooth speaker with PipeWire](https://www.collabora.com/news-and-blog/blog/2022/09/02/using-a-raspberry-pi-as-a-bluetooth-speaker-with-pipewire-wireplumber/)
- [Github - Using a Raspberry Pi as a Bluetooth® speaker with PipeWire](https://github.com/fdanis-oss/pw_wp_bluetooth_rpi_speaker)
- [Sound configuration on Raspberry Pi with ALSA](http://blog.scphillips.com/posts/2013/01/sound-configuration-on-raspberry-pi-with-alsa/)
- [PipeWire](https://docs.pipewire.org/)
- [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/)
- [Archlinux - WirePlumber](https://wiki.archlinux.org/title/WirePlumber#Keep_Bluetooth_running_after_logout_/_Headless_Bluetooth)
- [Archlinux - ALSA](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)
- [Gitlab - Pipewire as system service with PA tunnel needs clear documentation](https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2196)

### Get it running

```bash
# Upgrade system
sudo apt-get upgrade -y
# Add backport repo and GPG keys
echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/bullseye-backports.list
gpg --keyserver keyserver.ubuntu.com --recv-keys '0E98404D386FA1D9' '6ED0E7B82643E131'
gpg --export '0E98404D386FA1D9' '6ED0E7B82643E131' | sudo apt-key --keyring /etc/apt/trusted.gpg.d/bullseye-backports.gpg add -
sudo apt-get update
# Install packages from backport repo
sudo apt-get install -t bullseye-backports -y pipewire wireplumber libspa-0.2-bluetooth
# Install DBus Python support
sudo apt-get install -y python3-dbus
# add group to user to use ALSA
sudo usermod -G audio sonos
# set auto-reconnect in Bluetooth settings
sudo sed -i 's/#JustWorksRepairing.*/JustWorksRepairing = always/' /etc/bluetooth/main.conf
sudo systemctl restart bluetooth.service

# Configure Speaker-Agent service
cp speaker-agent.py ~
mkdir -p ~/.config/systemd/user/ && cp speaker-agent.service ~/.config/systemd/user/

# run Speaker-Agent as user context service
# ISSUE: Login needed.
systemctl --user --now enable speaker-agent.service

# or run Speaker-Agent as system service
# ISSUE: Initial login needed, logout possible though.
sudo sed -i 's/ \["with-logind"\] = true/ ["with-logind"] = false/' /usr/share/wireplumber/bluetooth.lua.d/50-bluez-config.lua
loginctl enable-linger
sudo cp artifacts/speaker-agent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl --now enable speaker-agent.service
```

### Debugging ALSA and DBus

- Set outbbut device with `sudo rasp-config`
- List ALSA playback hardware devices: `aplay -l` or `cat /proc/asound/cards`
- List all ALSA cards and devices: `aplay -L`
- Unmute and adjust ALSA output channel for default device: `amixer set PCM unmute` and `amixer set PCM 90%`
  or with `amixer controls`, `amixer cget numid=2` and `amixer cset numid=1 90%`
  or visual with with `alsamixer`
- Store the ALSA state to `/var/lib/alsa/asound.state`: `sudo alsactl store`
  this runs with `/etc/init.d/alsa-utils` on halt (runlevel 0, /etc/rc0.d/K01alsa-utils) and reboot (runlevel 6, /etc/rc6.d/K01alsa-utils)
- Generates stereo pink noise on default device: `speaker-test -c 2`
- Download and play wave file on default device: `wget http://www.pacdv.com/sounds/people_sound_effects/applause-1.wav` and `aplay applause-1.wav`
- Monitor system message bus `dbus-monitor --system --profile`

- Show Bluetooth config: `bluetoothctl show`

- Show WirePlumber user context service: `systemctl --user status wireplumber.service`
- Show PipeWire user context service: `systemctl --user status pipewire.service`
- Show WirePlumber config: `wpctl status`
- Show PipeWire data streams: `pw-top`
- Show PipeWire daemon state: `pw-mon`
- Show PipeWire server info: `pw-cli info 0`

## Running in Docker

```bash
docker build -t bluetooth-receiver .
docker run --rm -ti --net=host --privileged bluetooth-receiver
```

## Running within WSL

### Sources

- [Stackoverflow - bluetooth in docker for windows host](https://stackoverflow.com/questions/65795071/bluetooth-in-docker-for-windows-host)
- [Github - How to make a USB bluetooth adapter work with WSL](https://github.com/dorssel/usbipd-win/discussions/310)

### Requirements

- Windows 10 build 19041 x64
- [Windows Subsystem for Linux - WSL](https://learn.microsoft.com/en-us/windows/wsl/)
- [Github - USBIPD support for WSL](https://github.com/dorssel/usbipd-win/wiki/WSL-support#building-your-own-usbip-enabled-wsl-2-kernel)

### Build own WSL kernel with additional drivers for Bluetooth

```powershell
wsl.exe --update
wsl.exe --install Debian
```

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential flex bison libssl-dev libelf-dev libncurses-dev autoconf libudev-dev libtool git bc python3 pahole pkg-config

# clone the kernel repo
git clone https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernel
uname -r # 5.15.133.1-microsoft-standard-WSL2+
git checkout linux-msft-wsl-5.15.y

# copy current configuration file
cp /proc/config.gz config.gz && gunzip config.gz && mv config .config
# set kernel options https://ubuntu.com/core/docs/bluez/reference/device-enablement/linux-kernel-configuration-options
# and https://www.kernelconfig.io/config_rfkill
make menuconfig
make -j $(getconf _NPROCESSORS_ONLN) && sudo make modules_install -j $(getconf _NPROCESSORS_ONLN) && sudo make install -j $(getconf _NPROCESSORS_ONLN)

# copy kernel image
sudo cp arch/x86/boot/bzImage /mnt/c/wslkernel/kernel-usbip

# enable kernel in .wslconfig
vi /mnt/c/Users/[user]/.wslconfig
```

```powershell
# Restart WSL
wsl.exe --shutdown
wsl.exe -d Debian
```

### Share USB device within WSL

```powershell
# run as Administrator
> usbipd.exe list
BUSID  VID:PID    DEVICE                                                        STATE
2-14   8087:0032  Intel(R) Wireless Bluetooth(R)                                Not shared

> usbipd.exe bind --busid 2-14
> usbipd.exe list
BUSID  VID:PID    DEVICE                                                        STATE
2-14   8087:0032  Intel(R) Wireless Bluetooth(R)                                Shared
```

```powershell
# run as normal user
> usbipd.exe attach --wsl --busid 2-14
> usbipd.exe list
BUSID  VID:PID    DEVICE                                                        STATE
2-14   8087:0032  Intel(R) Wireless Bluetooth(R)                                Attached
```

### Check working Bluetooth inside WSL

```bash
$ apt-get install -y usbutils bluetooth
$ apt-get install -y --no-install-recommends bluez-tools bluez-alsa-utils rfkill

$ lsusb
Bus 001 Device 002: ID 8087:0032 Intel Corp. AX210 Bluetooth

# insert modules
sudo modprobe bluetooth && sudo modprobe btusb && sudo modprobe bnep && sudo modprobe rfcomm
lsmod

# check bluetooth
ls -l /sys/class/bluetooth
dmesg

sudo ./entrypoint.sh

# DEBUGGING TOOLS
#
# btmon
# hcitool -i hci0 scan
# use bluetoothctl as default agent
/usr/bin/bluetoothctl --agent=NoInputNoOutput
> default-agent
> discoverable on
> pairable on
> scan on         # suchlauf starten
> scan off        # suchlauf beenden
> devices         # anzeige gefundene Geräte
> pair [Adresse]  # start Pairing
```

### Check working Bluetooth inside Docker

```powershell
docker.exe build -t bluetooth-receiver .
docker.exe run --privileged --rm -ti bluetooth-receiver
```

```bash
./entrypoint.sh
```

## Notes

- [Pairing Agents in BlueZ stack](https://technotes.kynetics.com/2018/pairing_agents_bluez/)
