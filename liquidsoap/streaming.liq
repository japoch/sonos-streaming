#!/usr/bin/liquidsoap

# Standard settings
settings.init.allow_root.set(true)
#log.level.set(4)
log.file.set(false)
#log.file.path.set("/var/log/liquidsoap/streaming.log")
log.stdout.set(true)
#set("log.file", false)
#set("log.stdout", true)
#init.daemon.set(false)
#init.daemon.pidfile.path.set("/var/run/liquidsoap/pi.pid")

#frame.audio.samplerate.set(48000)


# Enable replay gain
#enable_replaygain_metadata ()

#ice_pass = "hackme"
#ice_host = "icecast"
#ice_port = 8000
#ice_descr = "Phono audio streaming"
#ice_url = "http://phono.local"


# Get audio from phono
#phono = input.alsa(bufferize = false)
#phono = input.alsa(device="pcm.liquidsoap")

# Stream it out
#output.icecast(
#  %vorbis,
#  host = ice_host,
#  port = ice_port,
#  password = ice_pass,
#  mount = "phono.ogg",
#  phono
#)

#output.alsa(input.alsa(bufferize=false, device="plug:mic"))

# Successfully tested with Liquidsoap 1.4.4 & ALSA 1.1.3 (native)
# Low latency, no buffer underruns

set("frame.audio.size", 2048)
set("alsa.alsa_buffer", 8192)
set("alsa.buffer_length", 10)

input_analog = input.alsa(device="default", bufferize=true)
output.alsa(device="default", input_analog, bufferize=true)
