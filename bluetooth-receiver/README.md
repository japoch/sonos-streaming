# Bluetooth Receiver

## Running on Raspberry PI 2b Debian 11 "Bullseye"

**!DEPRECATED!**

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

## Running on Raspberry PI 2B Debian 11 "Bullseye"

Quellen:
- [Wie Sie den Raspberry Pi als “Bluetooth-Adapter” nutzen](https://www.pcwelt.de/article/1397754/wie-sie-den-raspberry-pi-als-bluetooth-adapter-nutzen.html)
- [Using a Raspberry Pi as a Bluetooth® speaker with PipeWire](https://github.com/fdanis-oss/pw_wp_bluetooth_rpi_speaker)

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
# Copy speaker agent files
cp speaker-agent.py ~
mkdir -p ~/.config/systemd/user/ && cp speaker-agent.service ~/.config/systemd/user/
# set auto-reconnect in Bluetooth settings
sudo sed -i 's/#JustWorksRepairing.*/JustWorksRepairing = always/' /etc/bluetooth/main.conf
sudo systemctl restart bluetooth.service
# start Systemd service in user context
systemctl --user enable --now speaker-agent.service
```

## Running in Docker

```bash
docker build -t bluetooth-receiver .
docker run --rm -ti bluetooth-receiver
```

## Running within WSL

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

## Howtos

- [Stackoverflow - bluetooth in docker for windows host](https://stackoverflow.com/questions/65795071/bluetooth-in-docker-for-windows-host)
- [Github - How to make a USB bluetooth adapter work with WSL](https://github.com/dorssel/usbipd-win/discussions/310)
- [Pairing Agents in BlueZ stack](https://technotes.kynetics.com/2018/pairing_agents_bluez/)
