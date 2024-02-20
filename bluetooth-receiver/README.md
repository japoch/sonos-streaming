# Bluetooth Receiver

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
