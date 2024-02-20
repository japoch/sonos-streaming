#!/bin/sh

# enable device
/bin/hciconfig hci0 up

# start dbus
service dbus start
# dbus-monitor --system

# start Bluetooth daemon (BlueZ)
/usr/sbin/bluetoothd &
#/usr/sbin/bluetoothd --nodetach --debug=DEBUG

#/usr/bin/bluetoothctl discoverable on
# enable page and inquiry scan
#/bin/hciconfig hci0 piscan
# sets Simple Pairing mode
#/bin/hciconfig hci0 sspmode 1

# manage incoming Bluetooth requests
/usr/bin/bt-agent --capability=NoInputNoOutput
