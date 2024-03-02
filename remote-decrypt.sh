#!/bin/bash
#
# The script expects the following environment variables to be set:
# - URL: where to download the key from. Use an obfuscated URL.
# - DEVICE: the device to open using cryptsetup luksOpen. It must contain
#   a LUKS-formatted file system.
# - VOLUME_NAME: the name of the volume that will be created. It contains
#   the deciphered data.

# Stores the path to the key file used to decrypt the data volume.
# Originally it is empty, but once the key has been downloaded from the
# internet, the path to the file is stored there.
key_file=""

download_key() {
  local url="$1"

  key_file=$(mktemp -f)
  wget -O "$key_file" "$url"
  echo "$key_file"
}

volume_is_mounted() {
  local volume_name="$1"

  dmsetup ls | grep "$volume_name"
}

mount_volume() {
  local volume_name="$1"
  local underlying_volume="$2"
  local key="$3"

  cryptsetup luksOpen -k "$key" "$underlying_volume" "$volume_name"
}

while true
do
  sleep 60
  [[ volume_is_mounted "$VOLUME_NAME" ]] && continue
  [[ -z "$key_file" ]] && key_file=$(download_key "$URL")
  [[ -n "$key_file" ]] && mount_volume "$VOLUME_NAME" "$DEVICE" "$key_file"
done