# gha-templates Repository

用於存放組織級別的GitHub Actions範本、設定等。

## 📋 概述

GitHub Actions的常用Pipeline範本內容，提供了企業級的CI/CD管道設計。

### 3+1層倉庫架構

1. **gha-templates Repo（本倉庫）** - Template Repo
   - 存放可重用的工作流模板（job, step, stage級別）
   - 提供核心CI/CD邏輯框架

2. **Pipelines Repo** - Pipeline管理主要Repo
   - 存放應用特定的配置、Dockerfile、K8s Manifests等
   - 支持RD團隊Fork & PR進行自訂配置

3. **App Repo** - 系統原始碼Repo
   - 存放應用系統原始碼
   - 在`.github/workflows/`中存放workflow觸發器

4. **Secrets Repo** - 機敏性設定Repo
   - 存放應用系統的機敏性設定內容，包含環境變數、憑證檔等
   - 應該只有少數人擁有權限存取


## 📁 目錄結構

```
gha-templates/
├── .github/workflows/                 # 可重用工作流定義
│   ├── job_*.yaml                    # Job級別工作流
│   └── stage_*.yaml                  # Stage級別完整工作流
├── actions/                          # Step級別Action設計
│   ├── checkout-repo/
│   ├── convert-json-to-env/                  
│   ├── copy-build-image-scripts/
│   ├── copy-files/
│   ├── deploy-approval/
│   ├── docker-run/
│   ├── load-variables/
│   ├── merge-env/
│   └── setup-folders/
├── dockerfiles/                    # Dockerfile等相關檔案
│   ├── baseImageDockerfiles/       # Base Image使用的Dockerfile
│   ├── fonts/                      # 全字庫的字型檔
│   ├── scripts/                    # Image中可能會需要的scripts
│   └── *.Dockerfile
├── k8s/                            # k8s佈署相關設定(Kustomization的Base)
├── scripts/                        # 執行Pipeline過程可能會需要的scripts檔案
└── variables/                      # Pipeline執行時預設載入的變數
```

此Repo的內容並非完全使用到，有一些內容為Azure DevOps Pipeline轉換之後建立，可能並未實際執行驗證過。