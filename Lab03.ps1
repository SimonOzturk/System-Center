Add-CMFallbackStatusPoint -SiteCode RDU -SiteSystemServerName RDU-CM-01.MTS.COM -StateMessageNum 5000 -ThrottleSec 3600
New-CMAccount -Name "MTS\CMClientInstaller" -SiteCode RDU -Password (Read-Host -AsSecureString -Prompt "Enter a password")
Get-CMClientPushInstallation
(Get-CMClientPushInstallation).Props | Where-Object PropertyName -eq "Advanced Client Command Line"
Set-CMClientPushInstallation -SiteCode RDU -AddAccount "MTS\CMClientInstaller" -EnableAutomaticClientPushInstallation $False -InstallationProperty "SMSSITECODE=RDU CCMEVALHOUR=12 SMSCACHESIZE=10000 SMSCACHEDIR=C:\CMCACHE FSP=RDU-CM-01"
(Get-CMClientPushInstallation).Props | Where-Object PropertyName -eq "Advanced Client Command Line"
Get-CMDevice -CollectionName "RDU Clients"
Get-CMDevice -CollectionName "RDU Clients" |Select-Object -Property Name,DeviceOS,IsClient
Install-CMClient -InputObject (Get-CMDevice -name "RDU-CL-01") -AlwaysInstallClient $true -ForceReinstall $true
Get-CMDevice -CollectionName "RDU Clients" | Select-Object -Property Name,DeviceOS,IsClient
Get-CMClientSetting
Get-CMClientSetting -Setting ClientPolicy
Get-CMClientSetting -Setting ComputerAgent
New-CMClientSetting -Name "Standard Desktop" -Type Device
Set-CMClientSetting -Name "Standard Desktop" -ClientPolicySettings -PolicyPollingInterval 30
Set-CMClientSetting -Name "Standard Desktop" -StateMessageSettings -StateMessagingReportingCycleMinutes 5
Set-CMClientSetting -Name "Standard Desktop" -ComputerAgentSettings -BrandingTitle "Mountain Technology Services"
Get-CMClientSetting -Name "Standard Desktop" -Setting ClientPolicy
Get-CMClientSetting -Name "Standard Desktop" -Setting ComputerAgent
Get-CMClientSetting -Name "Standard Desktop" -Setting StateMessaging
Start-CMClientSettingDeployment -ClientSettingName "Standard Desktop" -CollectionName "RDU Clients"
Invoke-CMClientAction -CollectionName "RDU Clients" -ActionType ClientNotificationRequestMachinePolicyNow
Get-CMClientStatusSetting
Set-CMClientStatusSetting -HardwareInventoryDayInterval 30 -SoftwareInventoryDayInterval 30 -ClientPolicyDayInterval 21 -HeartbeatDiscoveryDayInterval 21 -StatusMessageDayInterval 21
Get-CMClientStatusSetting
Get-CMClientStatusUpdateSchedule
Set-CMClientStatusUpdateSchedule -Interval 12 -UnitType Hours
Update-CMClientStatus -Force