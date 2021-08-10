Set-CMSoftwareDistributionComponent -SiteCode RDU -RetryCount 30 -DelayBeforeRetryingMins 20
Get-CMDistributionPoint
(Get-CMDistributionPoint).Properties.EmbeddedProperties."Server Remote Name"
(Get-CMDistributionPoint).Properties.EmbeddedProperties."Server Remote Name" | Format-Table -Property PropertyName,Value1
(Get-CMDistributionPoint).Properties.EmbeddedProperties."Server Remote Name" | Format-Table -Property PropertyName,@{l="DP Name";e={$PSItem.Value1}}
New-CMSiteSystemServer -ServerName "RDU-SVR-01.mts.com" -AccountName $null -SiteCode RDU

$14days=New-CMSchedule -RecurInterval Days -RecurCount 14
Add-CMDistributionPoint -SiteCode RDU -SiteSystemServerName "RDU-SVR-01.mts.com" -InstallInternetServer -ClientConnectionType Intranet -CertificateExpirationTimeUtc "05/28/2023 00:00:00" -MinimumFreeSpaceMB 5000 -PrimaryContentLibraryLocation E -PrimaryPackageShareLocation E -EnableContentValidation -ValidateContentSchedule $14days
(Get-CMDistributionPoint).Properties.EmbeddedProperties."Server Remote Name" | Format-Table -Property PropertyName,@{l="DP Name";e={$PSItem.Value1}}
Set-CMDistributionPoint -SiteSystemServerName "RDU-SVR-01.mts.com" -SiteCode RDU -AllowFallbackForContent $True -AddBoundaryGroupName "RDU Boundary Group"
New-CMDistributionPointGroup -Name RDU-DPs
Add-CMDistributionPointToGroup -DistributionPointName RDU-CM-01.MTS.COM -DistributionPointGroupName "RDU-DPs"
Add-CMDistributionPointToGroup -DistributionPointName RDU-SVR-01.MTS.COM -DistributionPointGroupName "RDU-DPs"

New-CMPackage -Name 7Zip -Description "7Zip, Open Source File Archiving Software" -Language English -Path "\\RDU-SVR-01\Software\7zip"
New-CMProgram -PackageName 7Zip -StandardProgramName 7ZipInstaller -DiskSpaceRequirement 4 -DiskSpaceUnit MB -DriveMode RenameWithUnc -Duration 20 -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights -RunType Hidden -CommandLine "7z1900-x64.exe /S"
Start-CMContentDistribution -PackageName 7Zip -DistributionPointGroupName RDU-DPs
New-CMPackageDeployment -CollectionName "RDU Clients" -StandardProgram -ProgramName 7ZipInstaller -PackageName 7Zip -DeployPurpose Required -ScheduleEvent AsSoonAsPossible -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally -SlowNetworkOption DoNotRunProgram
Invoke-CMClientAction -DeviceName RDU-CL-01 -ActionType ClientNotificationRequestMachinePolicyNow
Invoke-CMDeploymentSummarization -CollectionName "RDU Clients"
Get-CMDeploymentStatus | Where-Object ProgramName -eq "7ZipInstaller" | Select-Object -Property CollectionName,MessageDescription

New-CMApplication -Name "Adobe Reader" -Description "Adobe Acrobat Reader DC" -Publisher "Adobe, Inc." -SoftwareVersion "2020.009.20063"
Add-CMMsiDeploymentType -ApplicationName "Adobe Reader" -AddLanguage "en-US" -ContentLocation "\\rdu-svr-01\Software\Adobe\AcroRead.msi" -InstallationBehaviorType InstallForSystem -UserInteractionMode Hidden
Start-CMContentDistribution -ApplicationName "Adobe Reader" -DistributionPointGroupName RDU-DPs
New-CMApplicationDeployment -CollectionName "RDU Clients" -EnableSoftDeadline $true -DeadlineDateTime (Get-Date).AddMinutes(360) -DeployPurpose Required -DeployAction Install -UserNotification DisplayAll -Name "Adobe Reader"
Invoke-CMClientAction -DeviceName RDU-CL-01 -ActionType ClientNotificationRequestMachinePolicyNow
Invoke-CMClientAction -DeviceName RDU-CL-01 -ActionType ClientNotificationAppDeplEvalNow
Get-CMDeployment | Where-Object SoftwareName -eq "Adobe Reader"
Invoke-CMDeploymentSummarization -CollectionName "RDU Clients"
New-CMApplication -Name "PowerPoint" -Publisher "Microsoft Corporation" -SoftwareVersion 2010
Add-CMMsiDeploymentType -ContentFallback -ApplicationName "PowerPoint" -AddLanguage "en-US" -ContentLocation "\\RDU-SVR-01\Software\PowerPoint\ppviewer.msi" -UserInteractionMode Hidden -EstimatedRunTimeMins 5
New-CMGlobalConditionFile -Name "AdobeReaderInstall" -FileOrFolderName "AcroRd32.exe" -Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader"
Start-CMApplicationDeploymentSimulation -DeploymentAction Install -CollectionName "RDU Clients" -Name "PowerPoint"
Invoke-CMClientAction -CollectionName "RDU Clients" -ActionType ClientNotificationRequestMachinePolicyNow
Invoke-CMClientAction -DeviceName RDU-CL-01 -ActionType ClientNotificationAppDeplEvalNow
Invoke-CMDeploymentSummarization -CollectionName "RDU Clients"
Get-CMDeployment | Where-Object SoftwareName -eq "PowerPoint"
Get-CMApplicationRevisionHistory -Name "Adobe Reader"
Get-CMApplicationRevisionHistory -Name "Adobe Reader" | Select-Object -Property SDMPackageVersion,DateLastModified
