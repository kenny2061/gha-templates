FROM alpine as downloader

RUN wget https://github.com/elastic/apm-agent-dotnet/releases/download/v1.25.2/ElasticApmAgent_1.25.2.zip -O /tmp/ApmAgent.zip
RUN unzip /tmp/ApmAgent.zip -d /tmp/ApmAgent

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as base

# 找不到的Alpine packages：icu-data-full icu-libs krb5-libs libgcc libintl libstdc++ zlib
# 上面這些Alpine需要額外安裝的Packages是為了ICU(International Components for Unicode)
# Debian版的base image本身內建相關套件，所以不需要額外安裝
RUN apt update && apt install -y libssl1.1 tzdata curl unixodbc tini
RUN apt install -y \
    # 安裝字型
    fonts-wqy-microhei ttf-wqy-zenhei

# downgrading OpenSSL security level from 2 to 1
RUN sed -i 's/TLSv1.2/TLSv1/g' /etc/ssl/openssl.cnf \
&& sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

RUN echo "MinProtocol = TLSv1" >> /etc/ssl/openssl.cnf && echo "CipherString = DEFAULT@SECLEVEL=1" >> /etc/ssl/openssl.cnf

Copy --from=downloader /tmp/ApmAgent /apm_agent
