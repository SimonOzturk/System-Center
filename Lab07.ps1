Get-CMBootImage
Get-CMBootImage | Select-Object -Property Name,ImageOSVersion,PkgSourcePath | Format-Table -AutoSize
Set-CMBootImage -Name "Boot image (x64)" -EnableCommandSupport $True -EnableBinaryDeltaReplication $True -DeployFromPxeDistributionPoint $True -DisconnectUserFromDistributionPoint $True -DisconnectUserFromDistributionPointRetryCount 3 -DisconnectUserFromDistributionPointMins 3
Get-CMBootImage | Select-Object -Property Name,EnableLabShell,ForcedDisconnectEnabled,ForcedDisconnectDelay,ForcedDisconnectNumRetries

Import-CMDriver -UncFileLocation "\\RDU-SVR-01\Source\Drivers\Net\wnetvsc.inf" -EnableAndAllowInstall $True
Get-CMDriver | Select-Object -Property LocalizedDisplayName
New-CMDriverPackage -Name "Hyper-V Network Drivers" -Path "\\RDU-SVR-01\Source\Packages\Net"
Add-CMDriverToDriverPackage -DriverName "Microsoft Hyper-V Network Adapter" -DriverPackageName "Hyper-V Network Drivers"
Set-CMDriverBootImage -BootImageName "Boot image (x64)" -SetDriveBootImageAction AddDriverToBootImage -DriverName "Microsoft Hyper-V Network Adapter"

New-CMOperatingSystemImage -Name "Windows 10 Enterprise x64" -Path "\\RDU-SVR-01\Source\Images\OS\win10ref.wim"

Start-CMContentDistribution -BootImageName "Boot image (x64)" -DistributionPointName "RDU-SVR-01.mts.com"
Start-CMContentDistribution -DriverPackageName "Hyper-V Network Drivers" -DistributionPointName "RDU-SVR-01.mts.com"
Start-CMContentDistribution -OperatingSystemImageName "Windows 10 Enterprise x64" -DistributionPointName "RDU-SVR-01.mts.com"

$ClientID=Get-CMPackage -Fast | Where-Object Name -like "*Configuration Manager Client*" | Select-Object -ExpandProperty PackageId
$OSId=Get-CMOperatingSystemImage | Where-Object Name -like "*Windows 10 Enterprise*" | Select-Object -ExpandProperty PackageId
$BootId=Get-CMBootImage | Where-Object Name -like "*(x64)*" | Select-Object -ExpandProperty PackageId
New-CMTaskSequence -Name "Windows 10 Bare Metal Deploy" -InstallOperatingSystemImage -OperatingSystemImagePackageId $OSId -PartitionAndFormatTarget $True -LocalAdminPassword (Read-Host -AsSecureString -Prompt "Enter a password for local admin") -JoinDomain DomainType -DomainName "mts.com" -DomainAccount "mts\administrator" -DomainPassword (Read-Host -AsSecureString -Prompt "Enter the password for the domain administrator") -ClientPackagePackageId $ClientId -SoftwareUpdateStyle NoInstall -BootImagePackageId $BootId -OperatingSystemImageIndex 1

$Tsid=Get-CMTaskSequence | Where-Object Name -like "Windows 10*" | Select-Object -ExpandProperty PackageId
New-CMTaskSequenceDeployment -TaskSequencePackageId $Tsid -CollectionName "All Unknown Computers" -DeployPurpose Available -Availability MediaAndPxe -ShowTaskSequenceProgress $True -DeploymentOption DownloadContentLocallyWhenNeededByRunningTaskSequence

