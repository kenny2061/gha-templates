ARG IMAGE_SRC=mcr.microsoft.com/dotnet/aspnet:8.0-alpine
FROM alpine as downloader

RUN wget https://github.com/elastic/apm-agent-dotnet/releases/download/v1.25.2/ElasticApmAgent_1.25.2.zip -O /tmp/ApmAgent.zip
RUN unzip /tmp/ApmAgent.zip -d /tmp/ApmAgent

FROM ${IMAGE_SRC} as base

ENV LANG=zh_TW.utf8
ENV LANGUAGE=zh_TW

Copy --from=downloader /tmp/ApmAgent /apm_agent

Copy ./fonts/cns11643 /usr/share/fonts/cns11643/

Copy ./scripts/dotNet/dotNet-init.sh /usr/local/lib/init/
Copy ./scripts/shared/generateEnvVarsToStaticFile.sh /usr/local/lib/init/

RUN chmod +x /usr/local/lib/init/*.sh;

# 20231207:加入libgdiplus繪圖套件(libgdiplus)
# 加入Noto字型(顯示中文用) https://pkgs.alpinelinux.org/package/edge/community/x86/font-noto-all
# font-noto-all
# 為了在CloudRun透過NFS連接GCP FileStore
# nfs-utils libtool tini
# 地端連線NAS使用(cifs-utils)

RUN apk update && \
    apk add --no-cache \
    icu-data-full icu-libs \
    krb5-libs libgcc libintl libstdc++ zlib \
    tzdata curl unixodbc \
    libgdiplus \
    font-noto-all \
    nfs-utils libtool tini \    
    cifs-utils ca-certificates

RUN ls /usr/share/fonts -al; \
    ## 更改「Owner」和「Group」
    chown root:100 /usr/share/fonts/cns11643 -R; \
    ## 更改「檔案權限」
    chmod 644 /usr/share/fonts/cns11643/*; \
    ## 更改「資料夾權限」
    chmod 755 /usr/share/fonts/cns11643; \
    ## 更新「字型暫存資料」(安裝字型)
    fc-cache -fv; \
    fc-match --verbose sans;

# 上面的內容和AspNet8_Alpine_Base.Dockerfile一樣，如果拆分開來就可以只用下面的就好(就是要先Build base image，好處是減少下載檔案、套件安裝的時間)
# ARG IMAGE_SRC=mcr.microsoft.com/dotnet/aspnet:8.0-alpine
# FROM ${IMAGE_SRC}

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
ENV APP_NAME=${APP_NAME}
ENV APP_ROOT_DIR /app
ENV WEB_ROOT_DIR /app/wwwroot
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV ASPNETCORE_HTTP_PORTS=8080
ENV ASPNETCORE_URLS=http://+:8080

ENV MNT_BASE_DIR /mnt/nfs
ENV MNT_DIR /mnt/nfs/appdata
ENV MNT_LOGS_DIR /mnt/nfs/applogs

RUN mkdir /app

WORKDIR /app
EXPOSE 8080

COPY . .

RUN if [ -f buildImageCustomScript.sh ]; then sh buildImageCustomScript.sh; rm buildImageCustomScript.sh; fi

# 將複製進來的檔案都更改權限，避免無法執行
RUN chown -R 1000:1000 /app


# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/lib/init/dotNet-init.sh"]