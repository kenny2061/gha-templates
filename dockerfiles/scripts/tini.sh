#!/bin/sh
set -eo pipefail

if [[ -z ${MOUNT_NFS} ]]; then
    echo "MOUNT_NFS environment not set, skip mount nfs."
else
    if [[ $MOUNT_NFS == true ]]; then
        # Create mount directory for service.
        mkdir -p $MNT_BASE_DIR

        echo "Mounting Cloud Filestore."
        mount -o nolock $FILESTORE_IP_ADDRESS:/$FILE_SHARE_NAME $MNT_BASE_DIR
        
        if [ ! -d "$MNT_BASE_DIR/$APP_NAME/$PROGRAM_ENVIRONMENT" ]; then
            echo "Create folder $MNT_BASE_DIR/$APP_NAME/$PROGRAM_ENVIRONMENT"
            mkdir -p $MNT_BASE_DIR/$APP_NAME/$PROGRAM_ENVIRONMENT
        fi
        

        # Logs directory
        if [ ! -d "$MNT_BASE_DIR/$APP_NAME/logs/$PROGRAM_ENVIRONMENT" ]; then
            echo "Create log folder $MNT_BASE_DIR/$APP_NAME/logs/$PROGRAM_ENVIRONMENT"
            mkdir -p $MNT_BASE_DIR/$APP_NAME/logs/$PROGRAM_ENVIRONMENT
        fi

        umount $MNT_BASE_DIR

        echo "Create mount folder $MNT_DIR"
        mkdir -p $MNT_DIR
        mount -o nolock $FILESTORE_IP_ADDRESS:/$FILE_SHARE_NAME/$APP_NAME/$PROGRAM_ENVIRONMENT $MNT_DIR

        if [ ! -d "/app/appdata" ]; then
            echo "Create symbolic link $MNT_DIR to /app/appdata"
            ln -s $MNT_DIR /app/appdata
        fi

        echo "Create mount folder $MNT_LOGS_DIR"
        mkdir -p $MNT_LOGS_DIR
        mount -o nolock $FILESTORE_IP_ADDRESS:/$FILE_SHARE_NAME/$APP_NAME/logs/$PROGRAM_ENVIRONMENT $MNT_LOGS_DIR

        if [ ! -d "/app/applogs" ]; then
            echo "Create symbolic link $MNT_LOGS_DIR to /app/applogs"
            ln -s $MNT_LOGS_DIR /app/applogs
        fi

        echo "Mounting completed."

        echo "List content in $MNT_DIR"
        ls $MNT_DIR -al

        echo "List content in $MNT_LOGS_DIR"
        ls $MNT_LOGS_DIR -al
        
        echo "List content in /app/appdata"
        ls /app/appdata
        
        echo "List content in /app/applogs"
        ls /app/applogs
    fi
fi

if [ -f initCustomScript.sh ]; then ./initCustomScript.sh "$@"; rm initCustomScript.sh; fi
if [ -f unsetEnvVars.sh ]; then command $(cat unsetEnvVars.sh); fi
if [ -f /usr/local/lib/generateEnvVarsToStaticFile.sh ]; then /usr/local/lib/generateEnvVarsToStaticFile.sh; fi

# Start the application

echo "Start lanuch dotnet $APP"

dotnet $APP &

# Exit immediately when one of the background processes terminate.
wait -n
