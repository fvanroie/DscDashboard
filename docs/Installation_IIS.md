# Installation on Windows IIS

This page describes how to host the DSC Dashboard on a Windows computer using IIS.

## Summary

The `dashboard.ps1` script can run directly from PowerShell but it is recommended to host the site in IIS.
The DSCService already has a dependancy on IIS

## DSC Configuration

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
- The Pages folder from C:\Program Files\WindowsPowershell\Modules\DscDashboard\
    to C:\initpub\wwwroot\
