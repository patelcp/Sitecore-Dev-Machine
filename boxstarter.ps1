param
(
    [Switch]
    $InstallRequired = $false,

    [Switch]
    $InstallRecommended = $false,

    [String]
    $SqlServer2016IsoImage,

    [String]
    $SqlServer2016SaPassword,

    [String]
    $SqlServer2014IsoImage,

    [String]
    $SqlServer2014SaPassword
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

if ($InstallRequired)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallRequired" -Value "1"
}

if ($InstallRecommended)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallRecommended" -Value "1"
}

if ($SkipWindowsUpdate)
{
    Set-EnvironmentVariable -Key "BoxStarter:SkipWindowsUpdate" -Value "1"
}

if ($SqlServer2016IsoImage)
{
    Set-EnvironmentVariable -Key "choco:sqlserver2016:isoImage" -Value $SqlServer2016IsoImage

    if ($SqlServer2016SaPassword) {
        # enable mixed mode auth
        $env:choco:sqlserver2016:SECURITYMODE="SQL"
        $env:choco:sqlserver2016:SAPWD=$SqlServer2016SaPassword
    }
}

if ($SqlServer2014IsoImage)
{
    Set-EnvironmentVariable -Key "choco:sqlserver2014:isoImage" -Value $SqlServer2014IsoImage

    if ($SqlServer2014SaPassword) {
        # enable mixed mode auth
        $env:choco:sqlserver2014:SECURITYMODE="SQL"
        $env:choco:sqlserver2014:SAPWD=$SqlServer2014SaPassword
    }
}

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}

$currentPath = Get-ScriptDirectory
$installScript = "$currentPath\box.ps1"
$webLauncherUrl = "http://boxstarter.org/package/nr/url?$installScript"
$edgeVersion = Get-AppxPackage -Name Microsoft.MicrosoftEdge

if ($edgeVersion)
{
    start microsoft-edge:$webLauncherUrl
}
else
{
    $IE=new-object -com internetexplorer.application
    $IE.navigate2($webLauncherUrl)
    $IE.visible=$true
}
