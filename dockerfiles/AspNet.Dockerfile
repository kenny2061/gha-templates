FROM alpine as downloader

RUN wget https://github.com/elastic/apm-agent-dotnet/releases/download/v1.25.2/ElasticApmAgent_1.25.2.zip -O /tmp/ApmAgent.zip
RUN unzip /tmp/ApmAgent.zip -d /tmp/ApmAgent

ARG IMAGE_SRC=mcr.microsoft.com/dotnet/aspnet:8.0
FROM $IMAGE_SRC as base

# 找不到的Alpine packages：icu-data-full icu-libs krb5-libs libgcc libintl libstdc++ zlib
# 上面這些Alpine需要額外安裝的Packages是為了ICU(International Components for Unicode)
# Debian版的base image本身內建相關套件，所以不需要額外安裝
RUN apt update && apt install -y tzdata curl unixodbc tini
RUN apt install -y \
    # 安裝字型
    fonts-wqy-microhei ttf-wqy-zenhei

# 移除了libssl1.1套件(安裝時會顯示下列訊息)
# Unable to locate package libssl1.1
# Couldn't find any package by glob 'libssl1.1'
# 所以下面的設定也一併註解掉
# downgrading OpenSSL security level from 2 to 1
# RUN sed -i 's/TLSv1.2/TLSv1/g' /etc/ssl/openssl.cnf \
# && sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

# RUN echo "MinProtocol = TLSv1" >> /etc/ssl/openssl.cnf && echo "CipherString = DEFAULT@SECLEVEL=1" >> /etc/ssl/openssl.cnf

Copy --from=downloader /tmp/ApmAgent /apm_agent

# 上面的內容和AspNet8_Base.Dockerfile一樣，如果拆分開來就可以只用下面的就好(就是要先Build base image，好處是減少下載檔案、套件安裝的時間)

# ARG IMAGE_SRC=mcr.microsoft.com/dotnet/aspnet:8.0
# FROM $IMAGE_SRC

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
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/usr/local/lib/init/dotNet-init.sh"]