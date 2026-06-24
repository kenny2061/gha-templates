mkdir -p $WEB_ROOT_DIR

env | grep ^BUILD > $WEB_ROOT_DIR/cenvs.txt
env | grep ^DOTNET_ >> $WEB_ROOT_DIR/cenvs.txt
env | grep ^Serilog__ >> $WEB_ROOT_DIR/cenvs.txt
env | grep _ENVIRONMENT >> $WEB_ROOT_DIR/cenvs.txt

echo "BRANCH=$BRANCH" >> $WEB_ROOT_DIR/cenvs.txt
echo "APP_NAME=$APP_NAME" >> $WEB_ROOT_DIR/cenvs.txt

echo "ELASTIC_APM_SERVER_URL=$ELASTIC_APM_SERVER_URL" >> $WEB_ROOT_DIR/cenvs.txt
echo "Elastic_Search_Uri=$Elastic_Search_Uri" >> $WEB_ROOT_DIR/cenvs.txt
echo "Logging__SeriLog__ElasticSettings__ElasticUrl=$Logging__SeriLog__ElasticSettings__ElasticUrl" >> $WEB_ROOT_DIR/cenvs.txt
echo "ELASTIC_APM_STARTUP_HOOKS_LOGGING=$ELASTIC_APM_STARTUP_HOOKS_LOGGING" >> $WEB_ROOT_DIR/cenvs.txt
echo "ElasticApm__CentralConfig=$ElasticApm__CentralConfig" >> $WEB_ROOT_DIR/cenvs.txt
echo "ELASTIC_APM_LOG_LEVEL=$ELASTIC_APM_LOG_LEVEL" >> $WEB_ROOT_DIR/cenvs.txt
env | grep ^Logging__SeriLog__LogLevel__Elastic\\.Apm >> $WEB_ROOT_DIR/cenvs.txt

echo "Export some enviroment variables value to $WEB_ROOT_DIR/cenvs.txt"

if [ -n "$K_REVISION" ]; then
    if [ -d "/app/applogs" ]; then
        env > /app/applogs/$K_REVISION.env
    fi
elif [ -n "$MNT_LOGS_DIR" ]; then
    if [ -d "$MNT_LOGS_DIR" ]; then
        env > $MNT_LOGS_DIR/$K_REVISION.env
    fi
fi

if [ -n "$K_SERVICE" ]; then
    echo "CloudRun_Name=$K_SERVICE" >> $WEB_ROOT_DIR/cenvs.txt
    echo "$K_SERVICE" > $WEB_ROOT_DIR/crn.txt
fi