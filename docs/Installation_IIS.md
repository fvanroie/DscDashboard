# Installation on Windows IIS

This page describes how to host the DSC Dashboard on a Windows computer using IIS.

## Summary

The `dashboard.ps1` script can run directly from PowerShell but it is recommended to host the site in IIS.
The DSCService already has a dependancy on IIS

## DSC Configuration

```powershell
Configuration InstallDscDashboard
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost" {
        <#
            Install windows features
        #>
        WindowsFeature InstallIIS
        {
            Name = "Web-Server"
            Ensure = "Present"
        }

        "Web-WebSockets", "Web-Url-Auth", "Web-Windows-Auth" |
        ForEach-Object {
            $Package = $_

            WindowsFeature "Enable-$Package" {
                Name = $Package
                Ensure = "Present"
                DependsOn = "[WindowsFeature]InstallIIS"
            }
        }

        <#
            Download dotnet core hosting bundle
        #>
        xRemoteFile DownloadDotNetCoreHostingBundle
        {
            Uri = "https://download.microsoft.com/download/A/7/8/A78F1D25-8D5C-4411-B544-C7D527296D5E/dotnet-hosting-2.1.4-win.exe"
            DestinationPath = "C:\temp\dotnet-hosting-2.1.4-win.exe"
            MatchSource = $false
            #Proxy = "optional, your corporate proxy here"
            #ProxyCredential = "optional, your corporate proxy credential here"
        }

        # Discover your product name and id after installing it once with:
        #     Get-WmiObject Win32_product | Format-Table IdentifyingNumber,Name
        xPackage InstallDotNetCoreHostingBundle
        {
            Name = ".NET Core 2.1 Runtime & Hosting Bundle for Windows (v2.1.4)"
            ProductId = "CBC46E08-1043-4508-831E-1D5F07FD33AB"

            Arguments = "/quiet /norestart /log C:\temp\dotnet-hosting_install.log"
            Path = "C:\temp\dotnet-hosting-2.1.4-win.exe"

            DependsOn = @(
                "[WindowsFeature]InstallIIS",
                "[xRemoteFile]DownloadDotNetCoreHostingBundle"
            )
        }

        Script PutDotNetOnPath
        {
            SetScript = {
                $env:Path = $env:Path + "C:\Program Files\dotnet\;"
            }
            TestScript = {
                return ($env:path -split ';') -contains 'C:\Program Files\dotnet\'
            }
            GetScript = {
                return @{
                    SetScript = $SetScript
                    TestScript = $TestScript
                    GetScript = $GetSCript
                    Result = "Set dotnet path"
                }
            }
        }

        <#
            Download DscDashboard Module from GitHub
        #>
        xRemoteFile DownloadDscDashboard
        {
            Uri = "https://github.com/fvanroie/DscDashboard/archive/master.zip"
            DestinationPath = "C:\temp\DscDashboard.zip"
            MatchSource = $false
        }

        Archive UnzipDscDashboard
        {
            Path = "C:\temp\DscDashboard.zip"
            Destination = "C:\temp\"
            Ensure = "Present"
            DependsOn = "[xRemoteFile]DownloadDscDashboard"
        }

        $ModulePath = ($env:PSModulePath -split ';') |
            Where-Object { $_ -like "$env:ProgramFiles\*" } | Select-Object -First 1

        File InstallDscDashboard
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
            Recurse = $true # Ensure presence of subdirectories, too
            SourcePath = "C:\Temp\DscDashboard-master\DscDashboard"
            DestinationPath = "$ModulePath\DscDashboard"
            DependsOn = "[Archive]UnzipDscDashboard"
        }

        <#
            Download UniversalDashboard.Community Module from PowerShell Gallery
        #>
        Script DownloadUniversalDashboard {

            SetScript = {
                $ModuleName = 'UniversalDashboard.Community'
                $MinimumVersion = '2.0.1'

                $ProgressPreference = 'SilentlyContinue'
                Find-Module -Name $ModuleName -Min $MinimumVersion -Verbose:$false |
                Save-Module -Path 'C:\Temp\' -AcceptLicense -Verbose
            }
            GetScript = {
                $ModuleName = 'UniversalDashboard.Community'
                $MinimumVersion = '2.0.1'

                $result = $null
                try {
                    Import-Module -Name "C:\Temp\$ModuleName" -Min $MinimumVersion -Force -ErrorAction Stop -Verbose:$false
                    $currentVersion = (Get-module -Name $ModuleName).Version
                    Remove-Module -Name $ModuleName -Force -ErrorAction Stop -Verbose:$false
                } catch {}

                if ($result.count -gt 0) {
                    @{ 'Result' = "$currentVersion" }
                } else {
                    @{ 'Result' = "" }
                }
            }
            TestScript = {
                $ModuleName = 'UniversalDashboard.Community'
                $MinimumVersion = '2.0.1'

                try {
                    Import-Module -Name "C:\Temp\$ModuleName" -Min $MinimumVersion -Force -ErrorAction Stop -Verbose:$false
                    Remove-Module -Name $ModuleName -Force -ErrorAction Stop -Verbose:$false
                    return $true
                } catch {
                    return $false
                }

            }
        }
        
        $ModulePath = ($env:PSModulePath -split ';') |
            Where-Object { $_ -like "$env:ProgramFiles\*" } | Select-Object -First 1

        File InstallUniversalDashboard
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
            Recurse = $true # Ensure presence of subdirectories, too
            SourcePath = "C:\Temp\UniversalDashboard.Community"
            DestinationPath = "$ModulePath\UniversalDashboard.Community"
            DependsOn = "[Script]DownloadUniversalDashboard"
        }
        
    } # Node
} # Configuration
```

Save the configuration file as InstallDscDashboard.ps1

Next execute these steps to load *(dot source)*, compile and apply the configuration on the local computer:

```powershell
. .\InstallDscDashboard.ps1
InstallDscDashboard -OutputPath . -Verbose
Start-DscConfiguration -Path .\InstallDscDashboard -Computername localhost -Wait -Verbose
```

You now have installed the DSC Dashboard site in IIS. Browse to http://localhost to view the result.

## Manual Steps

### Install IIS and Websockets

```powershell
PS> Install-WindowsFeature "Web-Server","Web-WebSockets"

Display Name                                            Name                       Install State
------------                                            ----                       -------------
[X] Web Server (IIS)                                    Web-Server                     Installed
            [X] WebSocket Protocol                      Web-WebSockets                 Installed
```

Websockets needs to be installed and enabled in IIS for the dashboard to work properly.

### Install .Net Core Hosting Bundle

Universal Dashboard needs the .Net Core Hosting package to 
[run in IIS](https://adamdriscoll.gitbooks.io/powershell-universal-dashboard/content/running-dashboards/iis.html):
- [.NET Core 2.1 Runtime & Hosting Bundle for Windows (v2.1.4)](https://www.microsoft.com/net/download/dotnet-core/2.1)

__Important:__
> Install the dotnet-hosting-2.1.4-win.exe package after you have installed IIS, otherwise some paths
> will get overwritten by the IIS installation and you need to re-install the .Net Core Hosting package.

Reboot the server to make the changes to the environment variables active.


### Install the modules

Download and install the DscDashboard and UniversalDashboard modules in the folder C:\Program Files\WindowsPowershell\Modules:

```powershell
PS> Get-Module -Name "*Dashboard*" -ListAvailable

    Directory: C:\Program Files\WindowsPowerShell\Modules

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.0.1      DscDashboard                        {New-DscDashboardCustomHeader...}
Script     2.0.1      UniversalDashboard.Community        {New-UDChart, New-UDDashboard...}
```

They need to be accessible by the dashboard.ps1 script that runs in IIS.


### Copy files to wwwroot

We will use the IIS Default Website location to host the dashboard instead of the default placeholder website.
You can use another directory if the Default Website is already used to host a site.

Copy:
- The entire contents of C:\Program Files\WindowsPowershell\Modules\UniversalDashboard
    to C:\initpub\wwwroot\
- The file dashboard.ps1 file from C:\Program Files\WindowsPowershell\Modules\DscDashboard\
    to C:\initpub\wwwroot\
- The file Pages folder from C:\Program Files\WindowsPowershell\Modules\DscDashboard\
    to C:\initpub\wwwroot\
