<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER DoNotInstallRequired

.PARAMETER InstallRecommended

.EXAMPLE
Open IE or Edge browser and navigate to following URL: https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/box.ps1

.EXAMPLE

.NOTES

#>
param
(
    [Switch]
    $SkipInstallRequiredApps = $false,

    [Switch]
    $SkipInstallRecommendedApps = $false,

    [Switch]
    $SkipSitcoreTools = $false,

    [Switch]
    $SkipWindowsUpdate = $false
)

function Set-EnvironmentVariable
{
    param
    (
        [String]
        [Parameter(Mandatory=$true)]
        $Key,

        [String]
        [Parameter(Mandatory=$true)]
        $Value
    )

    [Environment]::SetEnvironmentVariable($Key, $Value, "Machine") # for reboots
	[Environment]::SetEnvironmentVariable($Key, $Value, "Process") # for right now

}

if ($SkipInstallRequiredApps)
{
    Set-EnvironmentVariable -Key "BoxStarter:SkipInstallRequiredApps" -Value "1"
}

if ($SkipInstallRecommendedApps)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallRecommendedApps" -Value "1"
}

if ($SkipSitcoreTools)
{
    Set-EnvironmentVariable -Key "BoxStarter:SkipSitcoreTools" -Value "1"
}

if ($SkipWindowsUpdate)
{
    Set-EnvironmentVariable -Key "BoxStarter:SkipWindowsUpdate" -Value "1"
}
<#
if ($SqlServer2016IsoImage)
{
    Set-EnvironmentVariable -Key "choco:sqlserver2016:isoImage" -Value $SqlServer2016IsoImage

    if ($SqlServer2016SaPassword) {
        # enable mixed mode auth
        $env:choco:sqlserver2016:SECURITYMODE="SQL"
        $env:choco:sqlserver2016:SAPWD=$SqlServerSaPassword
    }
}

if ($SqlServer2014IsoImage)
{
    Set-EnvironmentVariable -Key "choco:sqlserver2014:isoImage" -Value $SqlServer2014IsoImage

    if ($SqlServer2014SaPassword) {
        # enable mixed mode auth
        $env:choco:sqlserver2014:SECURITYMODE="SQL"
        $env:choco:sqlserver2014:SAPWD=$SqlServerSaPassword
    }
}
#>
$installScript = "https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/box.ps1"
$webLauncherUrl = "http://boxstarter.org/package/nr/url?$installScript"
$edgeVersion = Get-AppxPackage -Name Microsoft.MicrosoftEdge

if ($edgeVersion)
{
    Start-Process microsoft-edge:$webLauncherUrl
}
else
{
    $IE=new-object -com internetexplorer.application
    $IE.navigate2($webLauncherUrl)
    $IE.visible=$true
}