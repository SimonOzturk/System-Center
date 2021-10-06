Get-CMSecurityRole
Get-CMSecurityRole | Select-Object -Property RoleName,IsBuiltIn,NumberOfAdmins,RoleID,CopiedFromID | Format-Table -AutoSize
Copy-CMSecurityRole -Name "Backup Administrator" -SourceRoleName "Full Administrator"
Get-CMSecurityRole | Select-Object -Property RoleName,IsBuiltIn,NumberOfAdmins,RoleID,CopiedFromID | Format-Table -AutoSize

New-CMSecurityScope -Name "RDU Site"
Get-CMSecurityScope
Get-CMSecurityScope | Select-Object -Property CategoryName,NumberOfAdmins,NumberOfObjects

New-CMAdministrativeUser -Name "MTS\ascott" -RoleName "Backup Administrator" -SecurityScopeName "RDU Site"
Get-CMAdministrativeUser | Select-Object -Property RoleNames,LogonName,CategoryNames,CollectionNames

Add-CMEndpointProtectionPoint -SiteSystemServerName "RDU-CM-01.mts.com" -ProtectionService DoNotJoinMaps
Get-CMEndpointProtectionPoint

New-CMAntiMalwarePolicy -Name "RDU Clients AM Policy" -Policy ScanSettings,ScheduledScans,RealTimeProtection
Set-CMAntiMalwarePolicy -Name "RDU Clients AM Policy" -EnableScheduledScan $True -ScheduledScanType QuickScan -ScheduledScanWeekday Wednesday -ScheduledScanTime "12:00" -LimitCpuUsage 50
Set-CMAntiMalwarePolicy -Name "RDU Clients AM Policy" -ScanEmail $True -ScanNetworkDrive $False -ScanRemovableStorage $True -ScheduledScanUserControl ScanTimeOnly
Set-CMAntiMalwarePolicy -Name "RDU Clients AM Policy" -RealTimeProtectionOn $True -RealTimeScanOption ScanIncomingAndOutgoingFiles -ScanAllDownloaded $True

Start-CMAntiMalwarePolicyDeployment -AntimalwarePolicyName "RDU Clients AM Policy" -CollectionName "RDU Clients"

New-CMStatusFilterRule -Name "Site System Discovery Agent Start Messages" -SiteCode RDU -ComponentName SMS_WINNT_SERVER_DISCOVERY_AGENT -MessageType Milestone -MessageId 500 -SeverityType Informational -ForwardToStatusSummarizer $False

Set-CMStatusSummarizer -SiteCode RDU -ComponentStatusSummarizer -EnableStatusSummarizer $True -TimeThreshold 'Since 0:00:00'

Get-CMComponentStatusMessage -ComponentName SMS_MIGRATION_MANAGER -StartTime "1/1/2018" -SiteCode RDU
Get-CMComponentStatusMessage -ComponentName SMS_MIGRATION_MANAGER -StartTime "1/1/2020" -SiteCode RDU | Select-Object -Property Component,MessageId,MessageType,Time
Clear-CMComponentStatusMessageCount -ComponentName SMS_MIGRATION_MANAGER -Severity Information

Get-CMAlert
Get-CMAlert | Select-Object -Property Name,AlertState,DateFirstActivated,ID,Severity | Format-List
Get-CMAlert | Where-Object DateFirstActivated -gt "1/1/2020" | Select-Object -Property Name,AlertState,DateFirstActivated,ID,Severity | Format-List
$ID=Get-CMAlert | Where-Object {$_.Name -like "*DatabaseFreeSpaceWarning*"} | Select-Object -ExpandProperty ID
New-CMAlertSubscription -Name "Config DB Low Disk Space" -AlertId $ID -EmailAddress "ECMadmin@mts.com" -LocaleId 1033
Get-CMAlertSubscription

