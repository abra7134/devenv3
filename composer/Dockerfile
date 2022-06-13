FROM debian:9.13

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
    ;

ARG COMPOSER_VERSION="1.10.26"
ARG COMPOSER_DIST_SHA256="cbfe1f85276c57abe464d934503d935aa213494ac286275c8dfabfa91e3dbdc4"

RUN \
  set -eux \
    ;\
  COMPOSER_FILEPATH="/usr/local/bin/composer.phar" \
  COMPOSER_DIST_URL="https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
    ;\
  curl --silent \
    --output "${COMPOSER_FILEPATH}" \
    "${COMPOSER_DIST_URL}" \
    ;\
  echo "${COMPOSER_DIST_SHA256} ${COMPOSER_FILEPATH}" \
    | sha256sum --check \
    ;\
  ln --verbose \
    --symbolic \
    composer.phar \
    /usr/local/bin/composer \
    ;\
  chmod +x \
    /usr/local/bin/composer \
    ;

ENTRYPOINT ["/bin/true"]
