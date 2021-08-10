Add-CMSoftwareUpdatePoint -ClientConnectionType Intranet -WsusiisPort 8530 -SiteCode RDU -SiteSystemServerName "RDU-SVR-01.mts.com"
Set-CMSoftwareUpdatePointComponent -SiteCode RDU -SynchronizeAction DoNotSynchronizeFromMicrosoftUpdateOrUpstreamDataSource -EnableSyncFailureAlert $True -ImmediatelyExpireSupersedence $True -AddUpdateClassification "Security Updates","Update Rollups" -AddProduct "Windows 10"
Sync-CMSoftwareUpdate -FullSync $True

Get-CMSoftwareUpdate -Fast
Get-CMSoftwareUpdate -Fast | Select-Object -Property LocalizedDisplayName,DateRevised,CI_ID | Format-List
Get-CMSoftwareUpdate -Fast | Measure-Object

Invoke-CMClientAction -ActionType ClientNotificationRequestMachinePolicyNow -DeviceName "RDU-CL-01"
Invoke-CMSoftwareUpdateSummarization
# Takes Time :)
Get-CMSoftwareUpdate -Fast | Where-Object -Property NumMissing -gt 0
Get-CMSoftwareUpdate -Fast | Where-Object -Property NumMissing -gt 0 | Select-Object -Property LocalizedDisplayName,CI_ID

$updates=Get-CMSoftwareUpdate -Fast| Where-Object -Property NumMissing -gt 0

New-CMSoftwareUpdateGroup -Name "Windows 10 Updates" -InputObject $updates
Get-CMSoftwareUpdateGroup

New-CMSoftwareUpdateDeploymentPackage -Name "Deploy Windows 10 Updates" -Path "\\RDU-SVR-01\Source\Updates\Windows10"
Save-CMSoftwareUpdate -DeploymentPackageName "Deploy Windows 10 Updates" -SoftwareUpdateGroupName "Windows 10 Updates" -Location "\\RDU-SVR-01\WsusContent"
Start-CMContentDistribution -DeploymentPackageName "Deploy Windows 10 Updates" -DistributionPointGroupName RDU-DPs

New-CMSoftwareUpdateDeployment -CollectionName "RDU Clients" -SoftwareUpdateGroupName "Windows 10 Updates" -AllowRestart $True -DeadlineDateTime (Get-Date) -AvailableDateTime (Get-Date) -DeploymentType Required -SoftwareInstallation $False -TimeBasedOn LocalTime
Invoke-CMClientAction -ActionType ClientNotificationRequestMachinePolicyNow -DeviceName "RDU-CL-01"
Get-CMDeployment
Get-CMDeployment -CollectionName "RDU Clients"
Get-CMDeployment -CollectionName "RDU Clients" | Where-Object FeatureType -eq "5"
Invoke-CMSoftwareUpdateSummarization
Get-CMDeployment -CollectionName "RDU Clients" | Where-Object FeatureType -eq "5"


$30days=New-CMSchedule -RecurInterval Days -RecurCount 30
New-CMSoftwareUpdateAutoDeploymentRule -CollectionName "RDU Clients"-DeploymentPackageName "Deploy Windows 10 Updates" -Name "Win 10 Automatic Update Deployment" -AddToExistingSoftwareUpdateGroup $False -AllowRestart $False -DateReleasedOrRevised Last1Month -DeadlineImmediately $True -EnabledAfterCreate $True -RunType RunTheRuleOnSchedule -Schedule $30days -UpdateClassification "Update Rollups" -UserNotification HideAll -UseUtc $False
Invoke-CMSoftwareUpdateAutoDeploymentRule -Name "Win 10 Automatic Update Deployment"
Disable-CMSoftwareUpdateAutoDeploymentRule -Name "Win 10 Automatic Update Deployment"





