Get-CMDiscoveryMethod
Get-CMDiscoveryMethod | Where-Object { $_.ComponentName -like "SMS_AD*" }
Get-CMDiscoveryMethod | Where-Object { $_.ComponentName -like "SMS_AD*" } | Select-Object -Property ComponentName, Flag
Get-CMDiscoveryMethod | Where-Object { $_.ComponentName -like "SMS_AD*" } | Select-Object ComponentName, @{l = "Status"; e = { switch ($_.Flag) {
            2 { Write-Output "Disabled" }
            6 { Write-Output "Enabled" }
        }
    }
}
$14days=New-CMSchedule -RecurCount 14 -RecurInterval Days
Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -Enabled $true -EnableActiveDirectorySiteBoundaryCreation $true -PollingSchedule $14days -SiteCode RDU
(Get-CMDiscoveryMethod -Name ActiveDirectoryForestDiscovery).Properties.Props
(Get-CMDiscoveryMethod -Name ActiveDirectoryForestDiscovery).Properties.Props | Where-Object PropertyName -eq "Startup Schedule"
Convert-CMSchedule -ScheduleString "0001200000100070"
Invoke-CMForestDiscovery
Get-CMBoundary
Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -Enabled $true -AddActiveDirectoryContainer "ldap://ou=rdu clients,dc=mts,dc=com","ldap://ou=rdu servers,dc=mts,dc=com" -SiteCode RDU -EnableDeltaDiscovery $true -DeltaDiscoveryIntervalMins 15 -PollingSchedule $14days -AddAdditionalAttribute Department
(Get-CMDiscoveryMethod -Name ActiveDirectorySystemDiscovery).EmbeddedPropertyLists."AD     Containers"
(Get-CMDiscoveryMethod -Name ActiveDirectorySystemDiscovery).Properties.Props | Where-Object PropertyName -eq "Startup Schedule"
Convert-CMSchedule -ScheduleString "000120000011E000"
(Get-CMDiscoveryMethod -Name ActiveDirectorySystemDiscovery).Properties.Props | Where-Object PropertyName -eq "Full Sync Schedule"
Convert-CMSchedule -ScheduleString "0001200000100070"
Invoke-CMSystemDiscovery -SiteCode RDU
Get-CMDevice | Select-Object -Property Name
$UserSched=New-CMSchedule -RecurCount 7 -RecurInterval Days
Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -Enabled $true -AddActiveDirectoryContainer "ldap://ou=rdu users,dc=mts,dc=com","ldap://ou=clt users,dc=mts,dc=com" -SiteCode RDU -EnableDeltaDiscovery $true -DeltaDiscoveryMins 10 -PollingSchedule $UserSched -AddAdditionalAttribute Department,Division
(Get-CMDiscoveryMethod -Name ActiveDirectoryUserDiscovery).EmbeddedPropertyLists."AD Containers"
(Get-CMDiscoveryMethod -Name ActiveDirectoryUserDiscovery).Properties.Props | Where-Object PropertyName -eq "Startup Schedule"
(Get-CMDiscoveryMethod -Name ActiveDirectoryUserDiscovery).Properties.Props | Where-Object PropertyName -eq "Full Sync Schedule"
Convert-CMSchedule -ScheduleString "0001200000114000"
Convert-CMSchedule -ScheduleString "0001170000100038"
Invoke-CMUserDiscovery -SiteCode RDU
Get-CMUser | Select-Object -Property Name
$21days=New-CMSchedule -RecurInterval Days -RecurCount 21
$30days=New-CMSchedule -RecurInterval Days -RecurCount 30
New-CMDeviceCollection -LimitingCollectionName "All Systems" -Name "All Clients" -RefreshSchedule $21days -RefreshType Both
New-CMDeviceCollection -LimitingCollectionName "All Clients" -Name "RDU Clients" -RefreshSchedule $21days -RefreshType Both
New-CMDeviceCollection -LimitingCollectionName "All Systems" -Name "CM Servers" -RefreshSchedule $30days -RefreshType Periodic
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "All Clients" -QueryExpression "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT Workstation %'" -RuleName "All Clients"
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "RDU Clients" -QueryExpression "select * from SMS_R_System where SMS_R_System.SystemOUName = 'MTS.COM/RDU Clients'" -RuleName "RDU Clients"
Add-CMDeviceCollectionDirectMembershipRule -CollectionName "CM Servers" -Resource (Get-CMDevice -Name "RDU-CM-01")
Add-CMDeviceCollectionDirectMembershipRule -CollectionName "CM Servers" -Resource (Get-CMDevice -Name "RDU-SVR-01")
Set-CMCollectionMembershipEvaluationComponent -SiteCode RDU -MinutesInterval 30
Get-CMDeviceCollection
Get-CMDeviceCollection | Format-Table -Property Name,CollectionId,LimitToCollectionName,MemberCount

New-CMBoundary -Name "CLT Subnet 1" -Type IPSubnet -Value "172.17.32.0"
New-CMBoundary -Name "CLT Subnet 2" -Type IPSubnet -Value "172.17.48.0"
New-CMBoundaryGroup -Name "RDU Boundary Group"
New-CMBoundaryGroup -Name "CLT Boundary Group"
Add-CMBoundaryToGroup -BoundaryGroupName "RDU Boundary Group" -BoundaryName "MTS.COM/RDU"
Add-CMBoundaryToGroup -BoundaryGroupName "CLT Boundary Group" -BoundaryName "CLT Subnet 1"
Add-CMBoundaryToGroup -BoundaryGroupName "CLT Boundary Group" -BoundaryName "CLT Subnet 2"
Set-CMBoundaryGroup -Name "RDU Boundary Group" -DefaultSiteCode RDU
Set-CMBoundaryGroup -Name "CLT Boundary Group" -DefaultSiteCode RDU
Set-CMDistributionPoint -SiteSystemServerName "RDU-CM-01.MTS.COM" -AddBoundaryGroupName "RDU Boundary Group"
Get-CMBoundary
Get-CMBoundary | Select-Object DisplayName,-Value
Get-CMBoundaryGroup
Get-CMBoundaryGroup | Select-Object Name,DefaultSiteCode,MemberCount,SiteSystemCount
