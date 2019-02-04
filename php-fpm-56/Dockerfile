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
    php5.6-fpm \
    php5.6-bcmath \
    php5.6-curl \
    php5.6-gd \
    php5.6-mbstring \
    php5.6-mcrypt \
    php5.6-mysql \
    php5.6-intl \
    php5.6-sqlite3 \
    php5.6-soap \
    php5.6-xml \
    php-gearman \
    php-mongodb \
    php-ssh2 \
    php-xdebug \
    ;

COPY configs/ /

VOLUME ["/run/php"]

ENTRYPOINT ["/usr/sbin/php-fpm5.6", "--nodaemonize", "--fpm-config", "/etc/php/5.6/fpm/php-fpm.conf"]
