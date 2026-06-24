ARG NODE_VERSION=lts
FROM node:${NODE_VERSION}-alpine

ARG TARGET_FILE=server.js
ARG EXPOSE_PORT

ARG BUILD_ID
ARG BUILD_TIME
ARG BRANCH

# 加入Pipeline的一些資訊
ENV BUILD_ID=${BUILD_ID}
ENV BUILD_TIME=${BUILD_TIME}
ENV BRANCH=${BRANCH}

ENV APP_ROOT_DIR /app
ENV WEB_ROOT_DIR /app

ENV StartFile=${TARGET_FILE}
ENV ListenPort=${EXPOSE_PORT}
ENV PORT=${EXPOSE_PORT}

Copy ./scripts/react/react-init.sh /usr/local/lib/init/
Copy ./scripts/shared/mountGCPFilestore.sh /usr/local/lib/init/
Copy ./scripts/shared/generateEnvVarsToStaticFile.sh /usr/local/lib/init/

RUN chmod +x /usr/local/lib/init/*.sh;

RUN apk add tzdata curl nano tini

RUN if [ -f buildImageCustomScript.sh ]; then sh buildImageCustomScript.sh; rm buildImageCustomScript.sh; fi

RUN mkdir /app
RUN chown -R 1000:1000 /app

WORKDIR /app

COPY . .

EXPOSE ${ListenPort}

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/lib/init/react-init.sh"]

