#!/bin/bash

# 合併 YAML 檔案的函數，最多接受4個檔案，並將結果存到指定的檔案
merge_files() {
  local output_file=""
  local files=()
  local ignore_file_not_exist=false

  # 解析具名參數
  while [[ $# -gt 0 ]]; do
    case $1 in
      --output)
        output_file="$2"
        shift 2
        ;;
      --ignoreFileNotExist)
        ignore_file_not_exist=true
        shift
        ;;
      *)
        files+=("$1")
        shift
        ;;
    esac
  done

  # 檢查是否有至少一個檔案
  if [[ ${#files[@]} -lt 1 ]]; then
    echo "Error: You must provide at least 1 YAML file."
    return 1
  fi

  # 檢查輸出檔案是否已指定
  if [[ -z "$output_file" ]]; then
    echo "Error: Output file path is not provided."
    return 1
  fi

  # 過濾不存在的檔案
  local existing_files=()
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      existing_files+=("$file")
    else
      if [[ "$ignore_file_not_exist" == true ]]; then
        echo "Warning: File '$file' does not exist and will be ignored."
      else
        echo "Error: File '$file' does not exist."
        return 1
      fi
    fi
  done

  # 如果沒有任何檔案存在，直接退出
  if [[ ${#existing_files[@]} -eq 0 ]]; then
    echo "Error: None of the provided files exist."
    return 1
  fi

  # 如果只有一個檔案，直接複製到輸出路徑
  if [[ ${#existing_files[@]} -eq 1 ]]; then
    cp "${existing_files[0]}" "$output_file"
    echo "Only one file provided. It has been copied to: $output_file"
    sync  # 確保寫入磁碟
    return 0
  fi

  # 使用臨時檔案來避免競爭條件
  local temp_file=$(mktemp)

  # 構建 yq 命令的字串表達式
  #local yq_command="yq eval-all 'reduce .[] as \$item ({}; . * \$item)' ${existing_files[@]} > $temp_file"

  # 使用 eval 執行動態構建的 yq 命令
  #eval "$yq_command"

  yq eval-all '. as $item ireduce ({}; . * $item)' "${existing_files[@]}" > "$temp_file"


  # 檢查 yq 是否成功執行
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to merge files."
    rm "$temp_file"  # 刪除臨時檔案
    return 1
  fi

  # 確保結果不是空的
  if [[ -s "$temp_file" ]]; then
    mv "$temp_file" "$output_file"  # 將臨時檔案移動到最終輸出檔案
    echo "Merged YAML files saved to: $output_file"
    sync  # 確保寫入磁碟
  else
    echo "Error: Output file '$output_file' is empty."
    rm "$temp_file"
    return 1
  fi
}



# 將 YAML 檔案的所有 value 替換為指定符號的函式
replace_values() {
  local input_file="$1"
  local output_file="$2"
  local replace_symbol="$3"

  # 檢查是否傳入了正確數量的參數
  if [[ $# -ne 3 ]]; then
    echo "Error: You must provide exactly 3 arguments: input_file, output_file, and replace_symbol."
    return 1
  fi

  # 檢查輸入檔案是否存在
  if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' does not exist."
    return 1
  fi

  # 使用臨時檔案來避免競爭條件
  local temp_file=$(mktemp)

  # 使用 yq 替換 YAML 檔案中的值
  # yq eval "... |= (if (. == null) then . else $replace_symbol end)" "$input_file" > "$temp_file"
  yq eval "walk(if type == \"!!map\" or type == \"!!seq\" then . else \"$replace_symbol\" end)" "$input_file" > "$temp_file"

  # 檢查 yq 是否成功執行
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to replace values in '$input_file'."
    rm "$temp_file"  # 刪除臨時檔案
    return 1
  fi

  # 確認臨時檔案不是空檔案
  if [[ -s "$temp_file" ]]; then
    mv "$temp_file" "$output_file"
    echo "Values in '$input_file' have been replaced with '$replace_symbol' and saved to '$output_file'."
  else
    echo "Error: Output file '$output_file' is empty."
    rm "$temp_file"
    return 1
  fi

  # 強制將緩衝區資料寫入磁碟
  sync
}


# 將 YAML 檔案中的註解移除的函式
remove_comments() {
  local input_file="$1"
  local output_file="$2"

  # 檢查是否傳入了正確數量的參數
  if [[ $# -ne 2 ]]; then
    echo "Error: You must provide exactly 2 arguments: input_file and output_file."
    return 1
  fi

  # 檢查輸入檔案是否存在
  if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' does not exist."
    return 1
  fi

  # 使用臨時檔案來避免競爭條件
  local temp_file=$(mktemp)

  # 使用 yq 刪除 YAML 檔案中的註解
  yq eval '... comments=""' "$input_file" > "$temp_file"

  # 檢查 yq 是否成功執行
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to remove comments from '$input_file'."
    rm "$temp_file"  # 刪除臨時檔案
    return 1
  fi

  # 確認臨時檔案不是空檔案
  if [[ -s "$temp_file" ]]; then
    mv "$temp_file" "$output_file"
    echo "Comments removed from '$input_file' and saved to '$output_file'."
  else
    echo "Error: Output file '$output_file' is empty."
    rm "$temp_file"
    return 1
  fi

  # 強制將緩衝區資料寫入磁碟
  sync
}

update_kustomization_generator() {
  local yaml_file=""
  local env_file=""
  local secret_file=""

  # 解析參數
  while [[ $# -gt 0 ]]; do
    case $1 in
      --yaml_file=*)
        yaml_file="${1#*=}"
        shift
        ;;
      --env_file=*)
        env_file="${1#*=}"
        shift
        ;;
      --secret_file=*)
        secret_file="${1#*=}"
        shift
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

  # 檢查必要參數
  if [[ -z "$yaml_file" || -z "$env_file" || -z "$secret_file" ]]; then
    echo "Usage: update_kustomization_generator --yaml_file=FILE --env_file=FILE --secret_file=FILE"
    return 1
  fi

  # 備份
  #cp "$yaml_file" "${yaml_file}.bak"

  # 用 basename 取得純檔名，給 yq 使用
  local env_file_basename
  env_file_basename=$(basename "$env_file")
  local secret_file_basename
  secret_file_basename=$(basename "$secret_file")

  # 判斷 env_file 是否存在，不存在就移除 configMapGenerator 中對應設定

  if [[ ! -f "$env_file" ]]; then
    yq -i '(.spec.template.spec.containers[] | select(.name == "app").envFrom) |= map(select(has("configMapRef") | not))' "$deployment_file"
    yq -i 'del(.configMapGenerator)' "$yaml_file"
  fi

  # 判斷 secret_file 是否存在，不存在就移除 secretGenerator 中對應設定
  if [[ ! -f "$secret_file" ]]; then
    deployment_file="$(dirname $yaml_file)/deployment.yaml"
    yq -i '(.spec.template.spec.containers[] | select(.name == "app").envFrom) |= map(select(has("secretRef") | not))' "$deployment_file"
    yq -i 'del(.secretGenerator)' "$yaml_file"
  fi

  echo "Update complete for $yaml_file"
}

# 範例呼叫（你可改成從外部傳參數）
# update_kustomization_generator --yaml_file=kustomization.yaml --env_file=go-dev-envVars.env --secret_file=go-dev-envVars.secret