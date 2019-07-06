FROM debian:9.13-slim

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  apt-get -y update \
    ;\
  apt-get -y install \
    apt-transport-https \
    apt-utils \
    curl \
    gnupg2 \
    lsb-release \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  curl --silent https://nginx.org/keys/nginx_signing.key \
  | apt-key add - \
    ;\
  echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
  > /etc/apt/sources.list.d/nginx.list \
    ;\
  apt-get -y update \
    ;

ARG NGINX_VERSION="1.14.2"

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  { \
    echo "Package: nginx"; \
    echo "Pin: version ${NGINX_VERSION}-*"; \
    echo "Pin-Priority: 1001"; \
  } > /etc/apt/preferences.d/00nginx \
    ;\
  apt-get -y install \
    nginx \
    ;

ARG USER_ID=0
ARG GROUP_ID=0

RUN \
  set -eux \
    ;\
  if [ -n "${USER_ID}" -a "${USER_ID}" -gt 0 ]; \
  then \
    groupmod \
      --gid ${GROUP_ID} \
      www-data \
      ;\
    usermod \
      --uid ${USER_ID} \
      www-data \
      ;\
    mkdir --parents \
      ~www-data/ \
      ;\
    chown --changes \
      --recursive \
      www-data:www-data \
      ~www-data/ \
      ;\
  fi \
  ;

COPY root/ /

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off; master_process on;"]
