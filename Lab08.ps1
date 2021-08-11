Set-CMSite -Name "RDU Primary Site" -EnableWakeOnLan $True -WakeOnLanType UseWakeUpPacketsOnly -WakeOnLanTransmissionMethodType SubnetDirectedBroadcasts -RetryNumberOfSendingWakeUpPacketTransmission 5 -SendingWakeUpPacketTransmissionDelayMins 5
Get-CMSiteMaintenanceTask -SiteCode RDU
Get-CMSiteMaintenanceTask -SiteCode RDU | Format-Table -Property TaskName, Enabled, DaysOfWeek, DeleteOlderThan -AutoSize
#WARNING: The parameter 'MaintenanceTask' has been deprecated and may be removed in a future release.
#Set-CMSiteMaintenanceTask -SiteCode RDU -DeleteThanOlderDays 45 -MaintenanceTask DeleteAgedDiscoveryData -DaysOfWeek Sunday
#Set-CMSiteMaintenanceTask -SiteCode RDU -DeleteThanOlderDays 45 -MaintenanceTask DeleteInactiveClientDiscoveryData -DaysOfWeek Wednesday,Saturday -Enabled $True
Set-CMSiteMaintenanceTask -SiteCode RDU -DeleteThanOlderDays 45 -MaintenanceTaskName "Delete Aged Discovery Data" -DaysOfWeek Sunday -BeginTime "12:00AM"
Set-CMSiteMaintenanceTask -SiteCode RDU -MaintenanceTaskName "Delete Inactive Client Discovery Data" -Enabled $True -DeleteOlderThanDays 45 -BeginTime "3:00AM" -LatestBeginTime "5:00AM"

#WARNING: The parameter 'ThrottleMins' has been deprecated and may be removed in a future release. The parameter 'ThrottleSec' may be used as a replacement.
Add-CMFallbackStatusPoint -SiteSystemServerName "RDU-SVR-01.mts.com" -SiteCode RDU -StateMessageNum 5000 -ThrottleMins 90
(Get-CMFallbackStatusPoint -SiteCode RDU -SiteSystemServerName "RDU-SVR-01.mts.com").props

$storage = New-CMStorageFolder -StorageFolderName "D:\Userdata" -MaximumClientNumber 50 -MinimumFreeSpace 50 -SpaceUnit Gigabyte 
Add-CMStateMigrationPoint -SiteCode RDU -SiteSystemServerName "RDU-SVR-01.mts.com" -BoundaryGroupName "RDU Boundary Group" -StorageFolder $storage -TimeDeleteAfter 7 -TimeUnit Days

#Make Sure Windows PowerShell 5.1
#Reconnect to Primary Site
$smsprovider = Get-WmiObject -Class sms_providerlocation -Namespace "root\sms" -filter "ProviderForLocalSite=True"
$sitecode=$smsprovider.sitecode
$providermachine=$smsprovider.machine
Get-WmiObject -Class sms_SystemResourceList -Namespace root\sms\site_$sitecode -ComputerName $providermachine | Sort-Object -Property ServerRemoteName | Format-Table -Property ServerRemoteName,RoleName -GroupBy ServerRemoteName