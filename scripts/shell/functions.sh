copy_with_clear() {
    local sourcePath=""
    local targetPath=""
    local clearBeforeCopy=false

    # 解析具名參數
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --sourcePath) sourcePath="$2"; shift ;;
            --targetPath) targetPath="$2"; shift ;;
            --clearBeforeCopy) clearBeforeCopy="$2"; shift ;;
            *) echo "Unknown parameter passed: $1"; return 1 ;;
        esac
        shift
    done

    # 檢查sourcePath是否存在
    if [ ! -e "$sourcePath" ]; then
        echo "Error: Source path '$sourcePath' does not exist."
        return 1
    fi

    # 檢查targetPath是否存在，若不存在則建立目錄
    if [ ! -d "$targetPath" ]; then
        mkdir -p "$targetPath"
    fi

    # 如果clearBeforeCopy為true，清空targetPath目錄
    if [ "$clearBeforeCopy" = true ]; then
        echo "Clearing target directory '$targetPath'..."
        rm -rf "$targetPath"/*
    fi

    # 判斷sourcePath是檔案還是目錄並進行複製
    if [ -d "$sourcePath" ]; then
        echo "Copying directory '$sourcePath' to '$targetPath'..."
        cp -r "$sourcePath"/* "$targetPath"/
    else
        echo "Copying file '$sourcePath' to '$targetPath'..."
        cp "$sourcePath" "$targetPath"/
    fi
}

# 範例呼叫
# copy_with_clear --sourcePath "/path/to/source" --targetPath "/path/to/target" --clearBeforeCopy true
