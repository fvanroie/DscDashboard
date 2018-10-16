# Load the required Module Versions
try {
    Import-Module 'UniversalDashboard' -MinimumVersion 2.0.1 -ErrorAction 'Stop'
}
catch {
    Import-Module 'UniversalDashboard.Community' -MinimumVersion 2.0.1 -ErrorAction 'Stop'
}
finally {
    Import-Module 'DscDashboard'
}

# Default legend Options
$legendOptions =  @{
    legend = @{
        display = $true
        position = 'right'
    }
}

#region DSN Configuration

    $DscConnectionString = "DSN=DscDashboard; $env:DSC_SQL"
    if (!$DscConnectionString) {
        $DscConnectionString = 'DSN=DscDashboard'
    }

    try {
        Get-ODBCData -ConnectionString $DscConnectionString -query "Select TOP 1 * from Devices;" | Out-Null
    }
    catch {

        Start-UDDashboard -Dashboard (

            New-UDDashboard -Theme $Theme -Title "DSC Dashboard" -Footer $Footer -NavbarLinks $NavBarLinks -Content {
                New-UDHeading -Size 6 -Content { 'Unable to connect to the SQL Database. Please check the DSC_SQL environment variable or DscDashboard DSN.' }
            }

        ) -Wait #-Port 4242 -AutoReload # -Wait # This is needed for IIS
        return
    }

    $result = Get-ODBCData -query "select TOP 1 * from StatusReport;" -ConnectionString $DscConnectionString
    if (!$result) {

        Start-UDDashboard -Dashboard (

             New-UDDashboard -Theme $Theme -Title "DSC Dashboard" -Footer $Footer -NavbarLinks $NavBarLinks -Content {
                New-UDHeading -Size 6 -Content { 'SQL query failed' }
             }

        ) -Wait #-Port 4242 -AutoReload # -Wait # This is needed for IIS
        return
    }

#endregion

#region Scheduled Data Loader

    # Refresh the data once every minute
    $Schedule = New-UDEndpointSchedule -Every 60 -Second

    # Cache All Nodes every minute
    $RefreshAllNodes = New-UDEndpoint -Schedule $Schedule -Endpoint {
        $Cache:AllNodes = Get-DscDashboardNodes
    }

#endregion

# Get the pages
$PagesPath = Join-Path $PSScriptRoot "Pages"
$Footer = . (Join-Path $PagesPath "footer.ps1")

$Pages = @()
$Pages += . (Join-Path $PagesPath "home.ps1")

Get-ChildItem -Path $PagesPath -Exclude "home.ps1","footer.ps1" | ForEach-Object {
    $Pages += . $_.FullName
}

# The modules needs to be loaded in each process
$Initialization = New-UDEndpointInitialization -Module 'DscDashboard'

# Initialize the Dashboard
$Theme = Get-UDTheme "Default"

Start-UDDashboard -Endpoint $RefreshAllNodes -Dashboard (

    New-UDDashboard -Theme $Theme -Title "DSC Dashboard" -Pages $Pages -EndpointInitialization $Initialization -Footer $Footer -NavbarLinks $NavBarLinks # -CyclePagesInterval 150 -CyclePages

) -AutoReload -Port 4242 # -Wait is needed for hosting