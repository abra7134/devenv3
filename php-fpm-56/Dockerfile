FROM debian:10

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
    php5.6-fpm \
    php5.6-bcmath \
    php5.6-curl \
    php5.6-gearman \
    php5.6-gd \
    php5.6-mbstring \
    php5.6-mcrypt \
    php5.6-mongodb \
    php5.6-mysql \
    php5.6-intl \
    php5.6-sqlite3 \
    php5.6-soap \
    php5.6-ssh2 \
    php5.6-xdebug \
    php5.6-xml \
    php5.6-zip \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  apt-get -y install \
    git \
    imagemagick \
    mercurial \
    libdbi-perl \
    libdbd-mysql-perl \
    mariadb-client \
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

ENTRYPOINT ["/usr/sbin/php-fpm5.6", "--nodaemonize", "--fpm-config", "/etc/php/5.6/fpm/php-fpm.conf"]
