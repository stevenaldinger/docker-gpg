# GPG Docker Image

This allows you to run GPG commands using your host machine's `~/.ssh` and `~/.gnupg` directories.

## Building docker image

In the [Makefile](Makefile) there are commands for both building and pushing the image to [DockerHub](https://hub.docker.com/).

```sh
# Builds an image named 'stevenaldinger/docker-gpg:latest'
make build \
  dockerhub_user='stevenaldinger' \
  version="latest"
```

```sh
# Pushes an image to 'stevenaldinger/docker-gpg:latest'
make push \
  dockerhub_user='stevenaldinger' \
  version="latest"
```

## Usage

In general, when you run this docker image it will make sure the GPG agent is running and then it will run any command you pass in.

### Run the gpg daemon container

#### Example Docker Run

1. `cd` into the directory you want to export keys to.
2. Then run the container as a daemon:

```sh
docker run --rm --name gpg \
  -v "$HOME/.ssh":/root/.ssh \
  -v "$(pwd)/gnupg":/gnupg/USBDrive/gnupg \
  -d stevenaldinger/docker-gpg:latest \
  tail -f /dev/null
```

#### Example Docker-Compose

The [docker-compose.yml](docker-compose.yml) configuration runs `tail -f /dev/null` inside the container to keep it running and then the example files can be used to execute `gpg` commands inside the container.

Run `make run` to run a `stevenaldinger/docker-gpg:latest` container named `gpg`.

### Generate Passwordless keys

Run `make keys` with your desired email and name.

```sh
make keys \
 email=drone@grinsides.com \
 name='Drone Server'
```

### Generate Anonymous Passwordless keys

Run `make keys_anon` to generated anonymous credentials.
