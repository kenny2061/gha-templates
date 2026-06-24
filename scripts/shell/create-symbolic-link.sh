echo "TemplatesFolder: $TemplatesFolder"
echo "PipelinesFolder: $PipelinesFolder"
echo "SecretsFolder: $SecretsFolder"
echo "AppName: $AppName"

echo "ln -s $TemplatesFolder/k8s $PipelinesFolder/k8s-templates"
echo "==========目前$PipelinesFolder 目錄內容=========="
ls $PipelinesFolder -al
echo "==========刪除原本的目錄連結=========="
rm $PipelinesFolder/k8s-templates
rm $PipelinesFolder/secrets

ln -s $TemplatesFolder/k8s $PipelinesFolder/k8s-templates
ln -s $SecretsFolder/$AppName $PipelinesFolder/secrets

echo "==========建立連結後$PipelinesFolder 目錄內容=========="
ls $PipelinesFolder -al