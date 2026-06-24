FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine

# 參考這篇文章 https://www.mytechramblings.com/posts/running-a-sonarqube-scan-when-building-docker-image/

# 安裝需要的openJDK和NodeJS
RUN apk update && apk --no-cache add openjdk11 nodejs

# dotnet安裝SonarQube的Scanner和其它必要套件
RUN dotnet tool install --global dotnet-sonarscanner
RUN dotnet tool install --global coverlet.console
## Set the dotnet tools folder in the PATH env variable
ENV PATH="${PATH}:/root/.dotnet/tools"

# 產生報告的套件，用法參考 https://reportgenerator.io/usage
# nuget: https://www.nuget.org/packages/dotnet-reportgenerator-globaltool
RUN dotnet tool install --global dotnet-reportgenerator-globaltool

ENV SONAR_SERVER_URL ""
ENV SONAR_TOKEN ""
ENV SONAR_PROJECT_KEY ""

COPY scripts/DotNetSdkWithSonarQube_EntryPoint.sh /var/dotnetsdk_sq/entrypoint.sh

ENTRYPOINT ["/var/dotnetsdk_sq/entrypoint.sh"]