#!/bin/bash

# print the environment and exit without error if ctrl+c pressed
finish () {
  env
  echo 'Exiting...'
  exit 0
}

trap finish SIGINT

. "$HOME/.bashrc"

export GNUPGHOME=${GNUPGHOME:-'/root/.gnupg'}

main () {
  start_gpg_agent
  sleep 5
}

main

# if any arguments are supplied, run those, otherwise run the scripts
if [ "$#" != 0 ]
then
  $@
else
  if [ -z "$GNUPG_EMAIL_ADDRESS" ] || [ -z "$GNUPG_NAME_REAL" ]
  then
    echo "Environment variables 'GNUPG_EMAIL_ADDRESS' and 'GNUPG_NAME_REAL' must \
          be set in order to create a non-anonymous key."

    echo "Generating anonymous key..."

    # generate anonymous keys
    /usr/local/bin/gpg-key-gen.sh anonymous
  else
    export GNUPG_EMAIL_ADDRESS=${GNUPG_EMAIL_ADDRESS:-'drone@example.com'}
    export GNUPG_NAME_REAL=${GNUPG_NAME_REAL:-'Drone Server'}

    # generate keys
    /usr/local/bin/gpg-key-gen.sh
  fi
fi

exit 0
