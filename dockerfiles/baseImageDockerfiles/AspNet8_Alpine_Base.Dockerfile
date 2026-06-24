FROM alpine as downloader

RUN wget https://github.com/elastic/apm-agent-dotnet/releases/download/v1.25.2/ElasticApmAgent_1.25.2.zip -O /tmp/ApmAgent.zip
RUN unzip /tmp/ApmAgent.zip -d /tmp/ApmAgent

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine as base

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
