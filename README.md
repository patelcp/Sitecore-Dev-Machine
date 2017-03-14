# Sitecore-Dev-Machine

This scripts can be used to setup a Sitcore Development Workstation using [Boxstarter](http://boxstarter.org/) and [Chocolatey](https://chocolatey.org/).

## Software Installed

### Required Applications
**Windows Configurations Changes made**

    * Internet Information Services
            * Web Management Tools
                * IIS Management Console
                * IIS Management Scripts and Tools
            * World Wide Web Services
                * Application Development Features
                    * .NET Extensibility 4.6
                    * Application Initialization
                    * ASP.NET 4.6
                    * ISAPI Extensions
                    * ISAPI Filters
                * Common HTTP Features
                    * All but WebDAV Publishing
                * Health and Diagnostics
                    * All
                * Performance Features
                    * All
                * Security
                    * Basic Authentication
                    * Request Filtering

**Applications Installed**

    * [Visual Studio 2015 Professional](https://www.visualstudio.com/vs/)
    * Visual Studio Extensions
        * Web Essentials 2015.3
        * Sitecore Rocks
        * StyleCop
    * MS SQL Express 2014 SP2 w/ SQL Management Studio 2014 Express
    * Chocolatey
    * Google Chrome
    * Firefox
    * Flash Player Plugin
    * Adobe Reader
    * NodeJS
    * Sitecore Config Builder 1.4
    * Sitecore Log Analyzer
    * Sitecore Instance Manager (SIM)
    * Sitecore Diagnostics Toolset

### Recommended Applications

    * JDK 8
    * Git
    * Fiddler4
    * Nuget Commandline
    * Notepad++
    * SourceTree
    * DotPeek
    * Prefix
    * VS Code
        * C#
        * PowerShell
        * AzureRM Tools
        * VSCode Icons
        * Markdown Lint
    * Visual Studio Extensions
        * Productivity Power Tools 2015
        * Powershell Tools for Visaul Studio 2015
        * Spell Checker
        * Web Compiler
        * Web Analyzer
        * Markdown Editor
        * Gulp Snippet Pack

## How to use
Using a blank windows machine, run one of the below scripts in a elevated PowerShell terminal

### Manual Install
In Edge Or Internet Explorer, go to:
```http
http://boxstarter.org/package/url?https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1
```

### PowerShell

* Install Required and Recommended applications
```powershell
wget -Uri 'https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -InstallRecommendedApps }
```

* Install only the required applications

```powershell
wget -Uri 'https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -SkipInstallRecommendedApps}
```
* Install only the required applications and skip windows updates
```powershell
wget -Uri 'https://raw.githubusercontent.com/chiragp/Sitecore-Dev-Machine/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -SkipInstallRecommendedApps -SkipWindowsUpdate }
```

#### Arguments

|Argument|Type|Requires|Value Description|
|--------|----|--------|-----------------|
|SkipInstallRequiredApps|Switch||Skip installing and configurating machine with the required applications|
|SkipInstallRecommendedApps|Switch||Install and configures machine with the recommended applications|
|SkipWindowsUpdate|Switch||Skips running windows update|

