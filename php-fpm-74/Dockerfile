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
    gnupg2 \
    lsb-release \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  curl --silent https://packages.sury.org/php/apt.gpg \
  | apt-key add - \
    ;\
  echo "deb https://packages.sury.org/php/ `lsb_release -cs` main" \
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
    php7.4-fpm \
    php7.4-bcmath \
    php7.4-curl \
    php7.4-gearman \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-mongodb \
    php7.4-mysql \
    php7.4-intl \
    php7.4-sqlite3 \
    php7.4-soap \
    php7.4-ssh2 \
    php7.4-xdebug \
    php7.4-xml \
    php7.4-zip \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  apt-get -y install \
    git \
    mercurial \
    libdbi-perl \
    libdbd-mysql-perl \
    mariadb-client-10.1 \
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

ENTRYPOINT ["/usr/sbin/php-fpm7.4", "--nodaemonize", "--fpm-config", "/etc/php/7.4/fpm/php-fpm.conf"]
