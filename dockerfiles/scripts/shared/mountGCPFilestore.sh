#!/bin/sh
if [ -z "$MOUNT_NFS" ]; then
    echo "MOUNT_NFS environment not set, skip mount nfs."
else
    if [ "$MOUNT_NFS" = "true" ]; then
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

        if [ ! -d "$APP_ROOT_DIR/appdata" ]; then
            echo "Create symbolic link $MNT_DIR to $APP_ROOT_DIR/appdata"
            ln -s $MNT_DIR $APP_ROOT_DIR/appdata
        fi

        echo "Create mount folder $MNT_LOGS_DIR"
        mkdir -p $MNT_LOGS_DIR
        mount -o nolock $FILESTORE_IP_ADDRESS:/$FILE_SHARE_NAME/$APP_NAME/logs/$PROGRAM_ENVIRONMENT $MNT_LOGS_DIR

        if [ ! -d "$APP_ROOT_DIR/applogs" ]; then
            echo "Create symbolic link $MNT_LOGS_DIR to $APP_ROOT_DIR/applogs"
            ln -s $MNT_LOGS_DIR $APP_ROOT_DIR/applogs
        fi

        echo "Mounting completed."

        echo "List content in $MNT_DIR"
        ls $MNT_DIR -al

        echo "List content in $MNT_LOGS_DIR"
        ls $MNT_LOGS_DIR -al
        
        echo "List content in $APP_ROOT_DIR/appdata"
        ls $APP_ROOT_DIR/appdata
        
        echo "List content in $APP_ROOT_DIR/applogs"
        ls $APP_ROOT_DIR/applogs
    fi
fi
