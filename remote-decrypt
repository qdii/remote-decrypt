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
sleep_for_seconds=60

download_key() {
  local url="$1"

  key_file=$(mktemp)
  wget -O "$key_file" "$url" && echo "$key_file" || echo ""
}

volume_is_mounted() {
  local volume_name="$1"

  dmsetup ls | grep "$volume_name"
}

decrypt_volume() {
  local volume_name="$1"
  local underlying_volume="$2"
  local key="$3"

  echo "Decrypting volume"
  cryptsetup luksOpen --key-file "$key" "$underlying_volume" "$volume_name"
}

while true
do
  sleep "$sleep_for_seconds"
  volume_is_mounted "$VOLUME_NAME" && continue
  [[ -z "$key_file" ]] && echo "Downloading key" && key_file=$(download_key "$URL")
  [[ ! -f "$key_file" ]] && "Downloading key failed, retrying in ${sleep_for_seconds}s" && continue
  decrypt_volume "$VOLUME_NAME" "$DEVICE" "$key_file"
  volume_is_mounted "$VOLUME_NAME" && echo "Volume is mounted, deleting key." && rm "$key_file"
done
