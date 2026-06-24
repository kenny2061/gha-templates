ARG PHP_VERSION=lts
FROM php:${PHP_VERSION}-apache
# 參考 https://hub.docker.com/_/php

ARG BUILD_ID
ARG BUILD_TIME
ARG BRANCH
ARG APP_NAME

ENV MNT_BASE_DIR /mnt/nfs
ENV MNT_DIR /mnt/nfs/appdata
ENV MNT_LOGS_DIR /mnt/nfs/applogs
ENV APP_NAME=${APP_NAME}

# 加入Pipeline的一些資訊
ENV BUILD_ID=${BUILD_ID}
ENV BUILD_TIME=${BUILD_TIME}
ENV BRANCH=${BRANCH}

ENV APP_ROOT_DIR /var/www/html
ENV WEB_ROOT_DIR /var/www/html

RUN apt update && apt install -y libssl1.1 tzdata curl nano tini nfs-common cifs-utils nfs-kernel-server

Copy ./scripts/php/php-apache-init.sh /usr/local/lib/init/
Copy ./scripts/shared/mountGCPFilestore.sh /usr/local/lib/init/
Copy ./scripts/shared/generateEnvVarsToStaticFile.sh /usr/local/lib/init/

RUN chmod +x /usr/local/lib/init/*.sh;

RUN if [ -f buildImageCustomScript.sh ]; then sh buildImageCustomScript.sh; rm buildImageCustomScript.sh; fi

WORKDIR /var/www/html

COPY . .

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/usr/local/lib/init/php-apache-init.sh"]