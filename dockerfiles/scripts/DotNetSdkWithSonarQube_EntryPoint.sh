#!/bin/sh
set -e

if [ "$1" = "dotnet" ]; then
    if [ -z "$SONAR_SERVER_URL" ]; then
    echo "SONAR_SERVER_URL variable is empty, skip run sonarscanner."
    else
    echo "SONAR_SERVER_URL variable is set $SONAR_SERVER_URL, run sonarscanner and your command."
    dotnet sonarscanner begin /k:"$SONAR_PROJECT_KEY" /d:sonar.host.url="$SONAR_SERVER_URL" /d:sonar.login="$SONAR_TOKEN"
    
    $@

    dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"

    fi
else
    exec "$@"
fi