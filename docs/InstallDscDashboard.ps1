Configuration InstallDscDashboard
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost" {
        <#
            ---- Install windows IIS feature and dependencies
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
            ---- Download and install  dotnet core hosting bundle
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
            ---- Download, extract and install DscDashboard Module from GitHub
        #>
        xRemoteFile DownloadDscDashboard
        {
            Uri = "https://github.com/fvanroie/DscDashboard/archive/master.zip"
            DestinationPath = "C:\temp\DscDashboard.zip"
            MatchSource = $false
        }

        Archive ExtractDscDashboard
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
            DependsOn = "[Archive]ExtractDscDashboard"
        }

        <#
            ---- Download and install UniversalDashboard.Community Module from PowerShell Gallery
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
        
        <#
            ---- Copy all files to webfolder
        #>

        <#
            ---- Create IIS webapp
        #>



<#
            DependsOn = @("[Archive]InstallUniversalDashboard",
                          "[File]InstallDscDashboard",

                          "[WindowsFeature]InstallIIS",
                          "[WindowsFeature]Enable-Web-WebSockets",
                          "[WindowsFeature]Enable-Web-URL-Auth",
                          "[WindowsFeature]Enable-Web-Windows-Auth"

                          "[xPackage]InstallDotNetCoreHostingBundle",
                          "[Script]PutDotNetOnPath")
#>

    } # Node
} # Configuration