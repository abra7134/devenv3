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
  curl --silent https://www.dotdeb.org/dotdeb.gpg \
  | apt-key add - \
    ;\
  echo "deb http://packages.dotdeb.org jessie all" \
  > /etc/apt/sources.list.d/packages_dotdeb_org.list \
    ;\
  apt-get -y update \
    ;

RUN \
  set -eux \
    ;\
  export DEBIAN_FRONTEND=noninteractive \
    ;\
  { \
    echo "Package: nginx-*"; \
    echo "Pin: version 1.12.2-1~dotdeb+8.1"; \
    echo "Pin-Priority: 1001"; \
  } > /etc/apt/preferences.d/00nginx \
    ;\
  apt-get -y install \
    nginx-light \
    ;

COPY configs/ /

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off; master_process on;"]
