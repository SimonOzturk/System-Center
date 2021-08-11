function Connect-SMS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)][ValidateSet("RDU", "XXX")]
        [string]$SiteCode,
        [Parameter(Mandatory = $False, Position = 1)]
        [string]$Root = "RDU-CM-01.mts.com"
    )
    
    begin {
        
    }
    
    process {
        $initParams = @{}
        if ($null -eq (Get-Module ConfigurationManager)) {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
        }
        
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $Root @initParams
        if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $Root @initParams
        }
        Set-Location "$($SiteCode):\" @initParams
    }
    
    end {
        
    }
}