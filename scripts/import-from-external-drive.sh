#!/bin/bash

export EXTERNAL_DRIVE_NAME=${EXTERNAL_DRIVE_NAME:-"USBDrive"}
export EXTERNAL_DRIVE_PATH=${EXTERNAL_DRIVE_PATH:-"/gnupg/$EXTERNAL_DRIVE_NAME"}
export GNUPG_EMAIL_ADDRESS=${GNUPG_EMAIL_ADDRESS:-"anon@anonymous.com"}
export GNUPGHOME=${GNUPGHOME:-"$HOME/.gnupg"}

gpg_list_keys_long () {
  gpg --list-secret-keys --keyid-format LONG
}

import_from_external_drive () {
  gpg --import "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.public.gpg-key"
  gpg --allow-secret-key-import --import "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.private.gpg-subkeys"
  # gpg --allow-secret-key-import --import "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.private.gpg-key"
}

main () {
  # import only subkey and public key from thumb drive
  import_from_external_drive
  # list keys to ensure import worked
  gpg_list_keys_long
}

main
