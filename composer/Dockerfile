FROM debian:8.11@sha256:26dfc818af93a58695a5a3ef615ca63be387f6769ab2620be7e0716d8b474a48

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

ARG COMPOSER_VERSION="1.8.4"
ARG COMPOSER_DIST_SHA256="1722826c8fbeaf2d6cdd31c9c9af38694d6383a0f2bf476fe6bbd30939de058a"

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
