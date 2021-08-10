New-CMConfigurationItem -Name "Client Health Check Hour" -CreationType WindowsOS
New-CMConfigurationItem -Name "Client Health Check Interval" -CreationType WindowsOS
#New-CMBaseline -Name "**RDU Client Health Settings**"
New-CMBaseline -Name "RDU Client Health Settings"
Get-CMConfigurationItem -Fast | Select-Object LocalizedDisplayName,CI_ID
#Set-CMBaseline -Name "RDU Client Health Settings" -AddOSConfigurationItem "CI_ID *values** from line 5 above, comma separated"*
Set-CMBaseline -Name "RDU Client Health Settings" -AddOSConfigurationItem "16777719","16777720"
New-CMBaselineDeployment -Name "RDU Client Health Settings" -CollectionName "RDU Clients" -EnableEnforcement $True -OverrideServiceWindow $True
Invoke-CMClientAction -DeviceCollectionName "RDU Clients" -ActionType ClientNotificationRequestMachinePolicyNow
Get-CMBaseline -Name "RDU Client Health Settings" | Select-Object LocalizedDisplayName,ComplianceCount,NonComplianceCount
Invoke-CMBaselineSummarization

