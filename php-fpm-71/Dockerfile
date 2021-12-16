FROM debian:8.11

RUN \
  set -eux \
    ;\
  sed --in-place \
    '/jessie-updates/d' \
    /etc/apt/sources.list \
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

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  curl --silent https://packages.sury.org/php/apt.gpg \
  | apt-key add - \
    ;\
  echo "deb https://packages.sury.org/php/ jessie main" \
  > /etc/apt/sources.list.d/packages_sury_org_php.list \
    ;\
  apt-get -y update \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  apt-get -y install \
    php7.1-fpm \
    php7.1-bcmath \
    php7.1-curl \
    php7.1-gd \
    php7.1-mbstring \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-intl \
    php7.1-sqlite3 \
    php7.1-soap \
    php7.1-xml \
    php7.1-zip \
    php-gearman \
    php-mongodb \
    php-ssh2 \
    php-xdebug \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  apt-get -y install \
    git \
    libdbi-perl \
    libdbd-mysql-perl \
    mysql-client-5.5 \
    unzip \
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

VOLUME ["/run/php"]

ENTRYPOINT ["/usr/sbin/php-fpm7.1", "--nodaemonize", "--fpm-config", "/etc/php/7.1/fpm/php-fpm.conf"]
