$subscriptionname = Read-Host 'Enter subscription name' 
$resourceGroupName = Read-Host 'Enter shared resource group name'
$clientId=Read-Host 'Enter storage container(Tenant Id)'
$storageAccountName=Read-Host 'Enter storage account'
$storageContainer = $clientId.ToLower()
$storageAccountName = $StorageAccountName.ToLower()
#TODO: Default to subscription location?
$location = "West US"

Select-AzureRmSubscription -SubscriptionName $subscriptionname
New-AzureRmResourceGroup -Name $resourceGroupName  -Location $location -ErrorAction Continue -Force
New-AzureRmResourceGroupDeployment -Name SAGoldDeployment -ResourceGroupName $resourceGroupName -Mode Incremental -TemplateFile .\create-storage-account-standard\azuredeploy.json -newStorageAccountName $storageAccountName -storageAccountType "Standard_LRS" -location $location -container $clientId
#-TemplateParameterFile C:\prosarmtemplates\create-storage-account-standard\azuredeploy.parameters.json
$storageKey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey.Key1
if (!(Get-AzureStorageContainer -Context $storageContext -Name $storageContainer -ErrorAction SilentlyContinue) )  {
    New-AzureStorageContainer -Context $StorageContext -Name $storageContainer -Permission Off
}
Write-Host "wasb://$($storageContainer)@$($storageAccountName).blob.core.windows.net/"