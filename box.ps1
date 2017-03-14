# A BoxStarter script for use with http://boxstarter.org/WebLauncher
# Updates a Windows machine and installs a range of developer tools

# Allow unattended reboots
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$false
$Boxstarter.AutoLogin=$true

$checkpointPrefix = 'BoxStarter:Checkpoint:'

function Get-CheckpointName {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $CheckpointName
    )
    return "$checkpointPrefix$CheckpointName"
}

function Set-Checkpoint {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $CheckpointName,

        [Parameter(Mandatory=$true)]
        [string]
        $CheckpointValue
    )

    $key = Get-CheckpointName $CheckpointName
    [Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Machine") # for reboots
    [Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Process") # for right now
}

function Get-Checkpoint {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $CheckpointName
    )

    $key = Get-CheckpointName $CheckpointName
    [Environment]::GetEnvironmentVariable($key, "Process")
}

function Clear-Checkpoints {
    $checkpointMarkers = Get-ChildItem Env: | Where-Object { $_.name -like "$checkpointPrefix*" } | Select-Object -ExpandProperty name
    foreach ($checkpointMarker in $checkpointMarkers) {
        [Environment]::SetEnvironmentVariable($checkpointMarker, '', "Machine")
        [Environment]::SetEnvironmentVariable($checkpointMarker, '', "Process")
    }
}

function Get-SystemDrive {
    return $env:SystemDrive[0]
}

function Install-RequiredApps {
	choco install chocolatey 				--limitoutput
    choco install googlechrome              --limitoutput
    choco install firefox                   --limitoutput
    choco install flashplayerplugin         --limitoutput
    choco install adobereader               --limitoutput
    choco install nodejs.install			--limitoutput
    choco install nugetpackageexplorer	    --limitoutput

	choco install mssqlserver2014express	--limitoutput
	choco install mssqlservermanagementstudio2014express --limitoutput
}

function Install-RecommendedApps {
    choco install jdk8		        	    --limitoutput
    choco install git.install               --limitoutput
    choco install fiddler4               	--limitoutput
    choco install nuget.commandline		    --limitoutput
    choco install notepadplusplus.install   --limitoutput
    choco install linqpad4.install			--limitoutput
    #choco install poshgit                   --limitoutput
    choco install sourcetree 	            --limitoutput
    choco install dotpeek             	    --limitoutput
    choco install prefix               	    --limitoutput
}

function Install-WindowsUpdates {
    if (Test-Path env:\BoxStarter:SkipWindowsUpdate) {
        return
    }

    Write-BoxstarterMessage "Installing Windows update and reboot if necessary!"
    Enable-MicrosoftUpdate
    Install-WindowsUpdate -AcceptEula

    #if (Test-PendingReboot) { Invoke-Reboot }
}

function Install-WebPackage {
    param(
        $packageName,
        [ValidateSet('exe', 'msi')]
        $fileType,
        $installParameters,
        $downloadFolder,
        $url,
        $filename
    )

    $done = Get-Checkpoint -CheckpointName $packageName

    if ($done) {
        Write-BoxstarterMessage "$packageName already installed"
        return
    }


    if ([String]::IsNullOrEmpty($filename)) {
        $filename = Split-Path $url -Leaf
    }

    $fullFilename = Join-Path $downloadFolder $filename

    if (test-path $fullFilename) {
        Write-BoxstarterMessage "$fullFilename already exists"
        return
    }

    Get-ChocolateyWebFile $packageName $fullFilename $url
    Install-ChocolateyInstallPackage $packageName $fileType $installParameters $fullFilename

    Set-Checkpoint -CheckpointName $packageName -CheckpointValue 1
}

function Install-ClickOnceApp {
	param(
		$ApplicationName,
		$WebLauncherUrl
	)

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
}

function Install-SitecoreTools{
	$sitecoreToolsPath = "$dataDrive\Sitecore\tools"
	if(-not (Test-Path $sitecoreToolsPath)) {
        New-Item $sitecoreToolsPath -ItemType Directory
    }

	Install-ChocolateyZipPackage -PackageName 'Sitecore Config Builder 1.4' `
		-Url 'https://github.com/Sitecore/Sitecore-Config-Builder/releases/download/1.4.0.20/SCB.1.4.0.20.zip' `
		-UnzipLocation "$sitecoreToolsPath\ConfigBuilder"

	Install-ChocolateyZipPackage -PackageName 'Sitecore Log Analyzer' `
		-Url 'https://marketplace.sitecore.net/services/~/media/A99BCECAD8B44DA8B2CB27FC0BC6DD05.ashx?data=SCLA%202.0.0%20rev.%20140603&itemId=420d8d66-cc7f-4b59-a936-16c18cac13da' `
		-UnzipLocation "$sitecoreToolsPath\LogAnalyzer"	

	Install-ClickOnceApp -ApplicationName "Sitecore Instance Manager" -WebLauncherUrl "http://dl.sitecore.net/updater/sim/SIM.Tool.application"
	Install-ClickOnceApp -ApplicationName "Sitecore Diagnostics Toolset" -WebLauncherUrl "http://dl.sitecore.net/updater/sdt/Sitecore.DiagnosticsToolset.WinApp.application"
}

function Install-VisualStudio {
    # install visual studio 2015
    $VSCheckpoint = 'VisualStudio'
    $VSDone = Get-Checkpoint -CheckpointName $VSCheckpoint

    if (-not $done) {
        # choco install visualstudio2015community --limitoutput # -packageParameters "--AdminFile https://raw.githubusercontent.com/JonCubed/boxstarter/master/config/AdminDeployment.xml"
        choco install VisualStudio2015Professional -packageParameters "WebTools SQL" --limitoutput

        Set-Checkpoint -CheckpointName $VSCheckpoint -CheckpointValue 1
    }
}

function Install-VisualStudioExtensionsRequired {
    param (
        $DownloadFolder
    )

    $checkpoint = 'VSRequiredExtensions'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if (-not $done) {
    	Install-ChocolateyVsixPackage 'Web Essentials 2015.3' https://visualstudiogallery.msdn.microsoft.com/ee6e6d8c-c837-41fb-886a-6b50ae2d06a2/file/146119/48/Web%20Essentials%202015.3%20v3.0.235.vsix
        Install-ChocolateyVsixPackage 'Sitecore Rocks' https://visualstudiogallery.msdn.microsoft.com/44a26c88-83a7-46f6-903c-5c59bcd3d35b/file/35439/48/Sitecore.Rocks.VisualStudio.vsix
        Install-ChocolateyVsixPackage 'StyleCop' https://visualstudiogallery.msdn.microsoft.com/5441d959-387f-4cb2-a8c0-9998dd1fa49f/file/231103/2/StyleCop.vsix

        Install-WebPackage '.NET Core Visual Studio Extension' 'exe' '/quiet' $DownloadFolder https://go.microsoft.com/fwlink/?LinkID=827546 'DotNetCore.1.0.1-VS2015Tools.Preview2.0.3.exe' # for visual studio

        Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
    }
}

function Install-VisualStudioExtensionsRecommended {
    $checkpoint = 'VSRecommendedExtensions'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if (-not $done) {
        Install-ChocolateyVsixPackage 'Productivity Power Tools 2015' https://visualstudiogallery.msdn.microsoft.com/34ebc6a2-2777-421d-8914-e29c1dfa7f5d/file/169971/3/ProPowerTools.vsix 
        Install-ChocolateyVsixPackage 'PowerShell Tools for Visual Studio 2015' https://visualstudiogallery.msdn.microsoft.com/c9eb3ba8-0c59-4944-9a62-6eee37294597/file/199313/3/PowerShellTools.14.0.vsix
        Install-ChocolateyVsixPackage 'Spell Checker' https://visualstudiogallery.msdn.microsoft.com/7c8341f1-ebac-40c8-92c2-476db8d523ce/file/15808/12/SpellChecker.vsix
		Install-ChocolateyVsixPackage 'Web Compiler' https://visualstudiogallery.msdn.microsoft.com/3b329021-cd7a-4a01-86fc-714c2d05bb6c/file/164873/35/Web%20Compiler%20v1.10.300.vsix
        Install-ChocolateyVsixPackage 'Web Analyzer' https://visualstudiogallery.msdn.microsoft.com/6edc26d4-47d8-4987-82ee-7c820d79be1d/file/181923/24/Web%20Analyzer%20v1.7.77.vsix
		Install-ChocolateyVsixPackage 'Markdown Editor' https://visualstudiogallery.msdn.microsoft.com/eaab33c3-437b-4918-8354-872dfe5d1bfe/file/216970/26/Markdown%20Editor%20v1.11.201.vsix
		Install-ChocolateyVsixPackage 'Gulp Snippet Pack' https://visualstudiogallery.msdn.microsoft.com/9e26d1f9-1baf-4983-8c25-f5f769998d4f/file/205735/4/Gulp%20Snippet%20Pack%20v1.2.6.vsix

        Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
    }
}

function Install-VisualStudioCode {
    # install visual studio code and extensions
    choco install visualstudiocode	--limitoutput

    Update-Path

    $checkpoint = 'VSCodeExtensions'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if (-not $done) {
        # need to launch vscode so user folders are created as we can install extensions
        Start-Process code
        Start-Sleep -s 10

        code --install-extension ms-vscode.csharp
        code --install-extension ms-vscode.PowerShell
        code --install-extension msazurermtools.azurerm-vscode-tools
        code --install-extension robertohuertasm.vscode-icons
        code --install-extension DavidAnson.vscode-markdownlint
        #code --install-extension donjayamanne.githistory
        #code --install-extension msjsdiag.debugger-for-chrome

        Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
    }
}

function Install-InternetInformationServices {
    $checkpoint = 'InternetInformationServices'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if ($done) {
        Write-BoxstarterMessage "IIS features are already installed"
        return
    }

    # Enable Internet Information Services Feature - will enable a bunch of things by default
    choco install IIS-WebServerRole                 --source windowsfeatures --limitoutput

    # Web Management Tools Features
    choco install IIS-ManagementScriptingTools      --source windowsfeatures --limitoutput
    choco install IIS-IIS6ManagementCompatibility   --source windowsfeatures --limitoutput # installs IIS Metbase

    # Common Http Features
    choco install IIS-HttpRedirect                  --source windowsfeatures --limitoutput

    # .NET Framework 4.5/4.6 Advance Services
    choco install NetFx4Extended-ASPNET45           --source windowsfeatures --limitoutput # installs ASP.NET 4.5/4.6

    # Application Development Features
    choco install IIS-NetFxExtensibility45          --source windowsfeatures --limitoutput # installs .NET Extensibility 4.5/4.6
    choco install IIS-ISAPIFilter                   --source windowsfeatures --limitoutput # required by IIS-ASPNET45
    choco install IIS-ISAPIExtensions               --source windowsfeatures --limitoutput # required by IIS-ASPNET45
    choco install IIS-ASPNET45                      --source windowsfeatures --limitoutput # installs support for ASP.NET 4.5/4.6
    choco install IIS-ApplicationInit               --source windowsfeatures --limitoutput

    # Health And Diagnostics Features
    choco install IIS-LoggingLibraries              --source windowsfeatures --limitoutput # installs Logging Tools
    choco install IIS-RequestMonitor                --source windowsfeatures --limitoutput
    choco install IIS-HttpTracing                   --source windowsfeatures --limitoutput
    choco install IIS-CustomLogging                 --source windowsfeatures --limitoutput

    # Performance Features
    choco install IIS-HttpCompressionDynamic        --source windowsfeatures --limitoutput

    # Security Features
    choco install IIS-BasicAuthentication           --source windowsfeatures --limitoutput

	choco install UrlRewrite2 						--source webpi			 --limitoutput

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-NpmPackages {
    $checkpoint = 'NpmPackages'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if ($done) {
        Write-BoxstarterMessage "NPM packages are already installed"
        return
    }

    npm install -g gulp-cli
    npm install -g bower
    npm install -g yo
    npm install -g generator-helix

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-PowerShellModules {
    $checkpoint = 'PowerShellModules'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if ($done) {
        Write-BoxstarterMessage "PowerShell modules are already installed"
        return
    }

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
    Install-Module -Name Carbon
    Install-Module -Name PowerShellHumanizer
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Untrusted'

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Set-ChocoRequiredAppPins {
    # pin apps that update themselves
	#choco pin add -n=VisualStudio2015Professional
	#choco pin add -n=mssqlserver2014express
    choco pin add -n=googlechrome
    choco pin add -n=firefox
    #choco pin add -n=visualstudio2015community
}

function Set-ChocoRecommendedAppPins {
    # pin apps that update themselves
    choco pin add -n=visualstudiocode
    choco pin add -n=sourcetree
}

function Set-BaseSettings {
    $checkpoint = 'BaseSettings'
    $done = Get-Checkpoint -CheckpointName $Checkpoint

    if ($done) {
        Write-BoxstarterMessage "Base settings are already configured"
        return
    }

    Update-ExecutionPolicy -Policy Unrestricted

    $sytemDrive = Get-SystemDrive
    #Set-Volume -DriveLetter $sytemDrive -NewFileSystemLabel "System"

    # Show more info for files in Explorer
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar

    # Small taskbar
    Set-TaskbarOptions -Combine Always

    # replace command prompt with powershell in start menu and win+x
    Set-CornerNavigationOptions -EnableUsePowerShellOnWinX

    # Disable hibernate
    #Start-Process 'powercfg.exe' -Verb runAs -ArgumentList '/h off'

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Set-RequiredAppSettings {
    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe" -ErrorAction SilentlyContinue
	#Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe" -ErrorAction SilentlyContinue
}

function Set-RecommendedAppSettings {
	Install-ChocolateyPinnedTaskBarItem "${env:ProgramFiles(x86)}\Fiddler2\Fiddler.exe" -ErrorAction SilentlyContinue
	Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft VS Code\Code.exe" -ErrorAction SilentlyContinue
	Install-ChocolateyPinnedTaskBarItem "${env:ProgramFiles(x86)}\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\Ssms.exe" -ErrorAction SilentlyContinue

	Install-ChocolateyFileAssociation ".txt" "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe" -ErrorAction SilentlyContinue
    Install-ChocolateyFileAssociation ".dll" "$env:LOCALAPPDATA\JetBrains\Installations\dotPeek06\dotPeek64.exe" -ErrorAction SilentlyContinue
}

function New-InstallCache {
    param
    (
        [String]
        $InstallDrive
    )

    $tempInstallFolder = Join-Path $InstallDrive "temp\install-cache"

    if(-not (Test-Path $tempInstallFolder)) {
        New-Item $tempInstallFolder -ItemType Directory
    }

    return $tempInstallFolder
}

function Update-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

$dataDriveLetter = Get-SystemDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

# SQL Server requires some KB patches before it will work, so windows update first
Install-WindowsUpdates

# disable chocolatey default confirmation behaviour (no need for --yes)
choco feature enable --name=allowGlobalConfirmation

Set-BaseSettings

Write-BoxstarterMessage "Starting installs"

if (-not (Test-Path env:\BoxStarter:SkipInstallRequired)) {
    Write-BoxstarterMessage "Installing Required apps"

	Install-SitecoreTools
    
	Install-InternetInformationServices
    Install-RequiredApps
	Install-VisualStudio
	Install-VisualStudioExtensionsRequired -DownloadFolder $tempInstallFolder
    Install-NpmPackages

    # pin chocolatey app that self-update
    Set-ChocoRequiredAppPins

    # Add App shortcuts on taskbar
    Set-RequiredAppSettings
}

if (Test-Path env:\BoxStarter:InstallRecommendedApps) {
    Write-BoxstarterMessage "Installing Recommended apps"
    Install-RecommendedApps
    Install-VisualStudioCode
	
    # pin chocolatey app that self-update
    Set-ChocoRecommendedAppPins

    # Add App shortcuts on taskbar
    Set-RecommendedAppSettings
}

# install chocolatey as last choco package
choco install chocolatey --limitoutput

# re-enable chocolatey default confirmation behaviour
choco feature disable --name=allowGlobalConfirmation

if (Test-PendingReboot) {
    Invoke-Reboot 
}

# reload path environment variable
Update-Path

#Install-PowerShellModules

# set HOME to user profile for git
[Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")

# rerun windows update after we have installed everything
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdates

Clear-Checkpoints