#!/bin/bash

export EXTERNAL_DRIVE_NAME=${EXTERNAL_DRIVE_NAME:-"USBDrive"}
export EXTERNAL_DRIVE_PATH=${EXTERNAL_DRIVE_PATH:-"/gnupg/$EXTERNAL_DRIVE_NAME"}
export GNUPG_EMAIL_ADDRESS=${GNUPG_EMAIL_ADDRESS:-"anon@anonymous.com"}

export GNUPG_KEY_FILE="public"
export GNUPG_KEY_TYPE="gpg-key"

if [ "$1" == "private" ]
then
  export GNUPG_KEY_TYPE="gpg-subkeys"
  export GNUPG_KEY_FILE="private.gpg-subkeys"
fi

cat "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.$GNUPG_KEY_FILE.$GNUPG_KEY_TYPE"
