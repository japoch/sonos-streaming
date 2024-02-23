# startup/00_try-sh.sh
#for f in startup/*; do
#    source "$f" || exit 1
#    sleep 2s
#done

# startup 01_envs.sh
#export DISABLE_RTKIT=y
#export XDG_RUNTIME_DIR=/tmp
export PIPEWIRE_RUNTIME_DIR=/tmp
#export PULSE_RUNTIME_DIR=/tmp
#export DISPLAY=:0.0

# startup/10_dbus.sh
mkdir -p /run/dbus
dbus-daemon --system --fork

# startup/20_xvfb.sh
#Xvfb -screen $DISPLAY 1920x1080x24 &

# startup/30_pipewire.sh
mkdir -p /dev/snd
pipewire &
#pipewire-media-session &
#pipewire-pulse &
