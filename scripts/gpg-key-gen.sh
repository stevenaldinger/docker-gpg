#!/bin/bash

export EXTERNAL_DRIVE_NAME=${EXTERNAL_DRIVE_NAME:-"USBDrive"}
export EXTERNAL_DRIVE_PATH=${EXTERNAL_DRIVE_PATH:-"/gnupg/$EXTERNAL_DRIVE_NAME"}
export EXTERNAL_DRIVE_DIR="$EXTERNAL_DRIVE_PATH/gnupg"
export GNUPG_EMAIL_ADDRESS=${GNUPG_EMAIL_ADDRESS:-"anon@anonymous.com"}
export GNUPG_NAME_REAL=${GNUPG_NAME_REAL:-"Anonymous User"}
export GNUPG_NAME_COMMENT="Real name"
export GNUPGHOME="$(mktemp -d)"

gnupg_whitespace_trim () {
	local var=$@

	# remove leading whitespace characters
	var="${var#"${var%%[![:space:]]*}"}"

	# remove trailing whitespace characters
	var="${var%"${var##*[![:space:]]}"}"

	echo -n "$var"
}

generate_master_key () {
  if [ "$1" == "anonymous" ]
  then
    export GNUPG_NAME_REAL="Anonymous User"
    export GNUPG_NAME_COMMENT="Anonymous"
    export GNUPG_EMAIL_ADDRESS='anon@anonymous.com'
  fi

  cat > "gpg-key-info" <<EOF
    %echo Generating a GPG key with no password protection...
    %no-protection
    # Key-Type: RSA and RSA (default), sign/encrypt/auth
    Key-Type: RSA
    # Maximum key-length
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Usage: sign
    # maximum subkey-length
    Subkey-Length: 4096
    Name-Real: $GNUPG_NAME_REAL
    Name-Comment: $GNUPG_NAME_COMMENT
    Name-Email: $GNUPG_EMAIL_ADDRESS
    Expire-Date: 0
    # Do a commit here: performs the key generation
    %commit
    %echo Finished generating keys.
EOF

  gpg --expert --batch --generate-key "gpg-key-info"

  rm -rf gpg-key-info
}

generate_subkey () {
  gnupg_master_fingerprint=$(gnupg_whitespace_trim "$(gpg --list-secret-keys --keyid-format LONG | grep -A 1 sec | tail -1)")

  # create subkey with no password
  echo "" | gpg --quick-add-key --pinentry-mode=loopback --passphrase-fd 0 "$gnupg_master_fingerprint"
}

export_keys () {
  # export private key
  gpg --export-secret-keys --armor $GNUPG_EMAIL_ADDRESS > \<$GNUPG_EMAIL_ADDRESS\>.private.gpg-key

  gpg --export-secret-subkeys --armor $GNUPG_EMAIL_ADDRESS > \<$GNUPG_EMAIL_ADDRESS\>.private.gpg-subkeys

  # export public key
  gpg --export --armor $GNUPG_EMAIL_ADDRESS > \<$GNUPG_EMAIL_ADDRESS\>.public.gpg-key

  # export revocation key
  cp -a "$GNUPGHOME/openpgp-revocs.d/"*.rev \<$GNUPG_EMAIL_ADDRESS\>.rev
}

gpg_list_keys_long () {
  gpg --list-secret-keys --keyid-format LONG
}

backup_to_external_drive () {
  mkdir -p "$EXTERNAL_DRIVE_DIR/"
  cp -a \<$GNUPG_EMAIL_ADDRESS\>.* "$EXTERNAL_DRIVE_DIR/"
}

cleanup_gnupg_directories () {
  rm -rf \<$GNUPG_EMAIL_ADDRESS\>.*
  rm -rf "$GNUPGHOME"
}

delete_keys_from_keychain () {
  gnupg_master_fingerprint=$(gnupg_whitespace_trim "$(gpg --list-secret-keys --keyid-format LONG | grep -A 1 sec | tail -1)")

  gpg --yes --batch --quiet --delete-secret-keys "$gnupg_master_fingerprint"
  gpg --yes --batch --quiet --delete-keys "$gnupg_master_fingerprint"
}

import_from_external_drive () {
  export GNUPGHOME="$(mktemp -d)"

  gpg --import "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.public.gpg-key"
  gpg --allow-secret-key-import --import "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.private.gpg-subkeys"
  # gpg --allow-secret-key-import --import "$EXTERNAL_DRIVE_DIR/<$GNUPG_EMAIL_ADDRESS>.private.gpg-key"
}

main () {
  generate_master_key "$1"

  # list keys to see successful creation
  gpg_list_keys_long

  # generate subkey
  generate_subkey

  # list keys again to see new subkey was added
  gpg_list_keys_long

  # export private, public, and revocation keys to current directory
  export_keys

  # backup everything to thumb drive
  backup_to_external_drive

  echo "Deleting keys from keychain..."
  delete_keys_from_keychain

  # cleanup current directory and temp dir
  cleanup_gnupg_directories

  echo "No keys should exist anymore:"
  # list keys to ensure none exist
  gpg_list_keys_long

  # # import only subkey and public key from thumb drive
  # import_from_external_drive
  # # list keys to ensure import worked
  # gpg_list_keys_long
}

main "$1"
