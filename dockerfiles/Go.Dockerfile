ARG IMAGE_SRC=alpine:latest
FROM $IMAGE_SRC as base

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata curl tini nano

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8080

ARG TARGET_FILE
ARG APP_NAME
ARG BUILD_ID
ARG BUILD_TIME
ARG BRANCH

# 加入Pipeline的一些資訊
ENV BUILD_ID=${BUILD_ID}
ENV BUILD_TIME=${BUILD_TIME}
ENV BRANCH=${BRANCH}

ENV APP=/app/${TARGET_FILE}
ENV PATH=${PATH}:${APP}
ENV APP_NAME=${APP_NAME}
ENV APP_ROOT_DIR /app
ENV WEB_ROOT_DIR /app/wwwroot

Copy ./scripts/go/go-init.sh /usr/local/lib/init/
Copy ./scripts/shared/generateEnvVarsToStaticFile.sh /usr/local/lib/init/

RUN chmod +x /usr/local/lib/init/*.sh;

# COPY . .
COPY --chown=1000:1000 . .

RUN if [ -f buildImageCustomScript.sh ]; then sh buildImageCustomScript.sh; rm buildImageCustomScript.sh; fi

# 將複製進來的檔案都更改權限，避免無法執行
# RUN chown -R 1000:1000 /app
RUN find /app \( ! -user 1000 -o ! -group 1000 \) -exec chown 1000:1000 {} \;

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/lib/init/go-init.sh"]