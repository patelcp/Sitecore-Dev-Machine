# Sitecore-Dev-Machine

This scripts can be used to setup a Sitcore Development Workstation using [Boxstarter](http://boxstarter.org/) and [Chocolatey](https://chocolatey.org/).

## How to use
Using a blank windows machine, run one of the below scripts in a elevated PowerShell terminal

### Using bootstrap
1. Install only the required applications

```powershell
wget -Uri 'https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1"}
```
2. Install only the required applications and skip windows updates
```powershell
wget -Uri 'https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -SkipWindowsUpdate }
```

3. Install Required and Recommended applications
```powershell
wget -Uri 'https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -InstallRecommendedApps }
```

#### Arguments

|Argument|Type|Requires|Value Description|
|--------|----|--------|-----------------|
|SkipInstallRequired|Switch||Skip installing and configurating machine with the required applications|
|SkipWindowsUpdate|Switch||Skips running windows update|
|InstallRecommendedApps|Switch||Install and configures machine with the recommended applications|

### Manual 
Below method only installs the required applications.

In Edge Or Internet Explorer, go to:
```http
http://boxstarter.org/package/url??https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1
```