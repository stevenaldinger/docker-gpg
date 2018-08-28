# ======================== [START] main GPG image ======================= #
FROM ubuntu:18.04

ARG HOME="/root"
ARG APT_GET_DEPENDENCIES="\
 git \
 gnupg-agent \
 gnupg2 \
"

ENV \
 GPG="gpg2" \
 HOME="${HOME}"

RUN apt-get update \
 && apt-get install -y ${APT_GET_DEPENDENCIES} \
 && apt-get clean \
 && rm -rf "/var/lib/apt/lists/*" "/tmp/*" "/var/tmp/*"

WORKDIR /gnupg

COPY bashrc /root/.bashrc

COPY scripts/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/container_init.sh"]

CMD []
# ========================= [END] main GPG image ======================== #
