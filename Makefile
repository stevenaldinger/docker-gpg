# ==================== [START] Global Variable Declaration =================== #
SHELL := /bin/bash
# 'shell' removes newlines
BASE_DIR := $(shell pwd)

UNAME_S := $(shell uname -s)

# exports all variables
export
# ===================== [END] Global Variable Declaration ==================== #

# usage:
# make build \
#  dockerhub_user='stevenaldinger' \
#  version='0.0.1'
build:
	@docker build -f "${BASE_DIR}/Dockerfile" -t "$$dockerhub_user/docker-gpg:$$version" "${BASE_DIR}"

# usage:
# make push \
#  dockerhub_user='stevenaldinger' \
#  version='0.0.1'
push:
	@docker push "$$dockerhub_user/docker-gpg:$$version"

# usage:
# make run
run:
	@docker-compose -f "${BASE_DIR}/docker-compose.yml" up -d

# usage:
# make down
down:
	@docker-compose -f "${BASE_DIR}/docker-compose.yml" down

# usage:
# make keys \
#  email=drone@grinsides.com \
#  name='Drone Server'
keys:
	@docker exec -it \
	  gpg bash -c "\
	    export GNUPG_EMAIL_ADDRESS='$$email'; \
	    export GNUPG_NAME_REAL='$$name'; \
	    /usr/local/bin/gpg-key-gen.sh"

# usage:
# make keys_anon
keys_anon:
	@docker exec -it \
	  gpg bash -c "/usr/local/bin/gpg-key-gen.sh anonymous"
