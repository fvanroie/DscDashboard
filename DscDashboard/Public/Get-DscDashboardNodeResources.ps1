<#  MIT License

    Copyright (c) 2018 fvanroie, NetwiZe.be

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>


Function Get-DscDashboardNodeResources
{

    Param (
        [String]$AgentId
    )

    $Query = @"
        SELECT * from RegistrationData node
        OUTER APPLY(
            SELECT top 1 * FROM StatusReport report
            WHERE (node.AgentId=report.Id) AND (OperationType='Consistency') AND (StartTime<CURRENT_TIMESTAMP)
            ORDER BY report.StartTime desc
        ) AS [LastReport]
        WHERE AgentId = ?
"@

    $data = @()

    # Run the SQL query
    Get-ODBCData -Query $query -Dsn "DscDashboard" -parameter ([System.Data.Odbc.OdbcParameter]::new($null, $agentid)) |

    # Format the result
    ForEach-Object {

        # Extract Additional JSON data and convert it to PSObject
        Try
        {
            $AdditionalData = $_.AdditionalData | ConvertFrom-Json
            $OSVersion = $additionalData | Where-Object { $_.key -eq "OSVersion"} | select -ExpandProperty Value | ConvertFrom-Json | select -ExpandProperty VersionString
            $PSVersion = $additionalData | Where-Object { $_.key -eq "PSVersion"} | select -ExpandProperty Value | ConvertFrom-Json | select -ExpandProperty PSVersion
        }
        # If conversion fails, treat the data as a string
        Catch
        {
            $AdditionalData = $_.AdditionalData
            $OSVerion = 'Unknown'
            $PSVerion = 'Unknown'
        }

        # Extract Additional Status data and convert it to PSObject
        # We need to make this a valid JSON string before converting it
        Try
        {
            $StatusData = '{{"JSON":{0}}}' -f $_.StatusData | ConvertFrom-Json | select -ExpandProperty JSON | ConvertFrom-Json
        }
        # If conversion fails, treat the data as a string
        Catch
        {
            $StatusData = $_.StatusData
        }

        # Build NodeDetail Uri
        $NodeDetail = "/NodeDetail/{0}" -f $_.AgentId

        # Check Compliancy:
        $Compliancy, $Status = Get-DscDashboardNodeCompliancy -Status $_.Status -StartTime $_.StartTime -Url $NodeDetail `
            -RefreshFrequencyMins $StatusData.MetaConfiguration.RefreshFrequencyMins `
            -ResourcesNotInDesiredState $StatusData.ResourcesNotInDesiredState.count

        foreach ($resource in ($statusdata.ResourcesNotInDesiredState + $statusdata.ResourcesInDesiredState))
        {

            try
            {
                $dt = ([DateTime]$resource.StartDate).GetDateTimeFormats()[93]
            }
            Catch
            {

                try
                {
                    $dt = [DateTime]$resource.StartDate
                }
                Catch
                {
                    $dt = $resource.StartDate
                }


            }

            # Return Custom Object
            $data += [PSCustomObject]@{


                ConfigurationName = $resource.ConfigurationName
                Duration          = '{0} s.' -f $resource.DurationInSeconds
                InDesiredState    = $resource.InDesiredState
                InstanceName      = $resource.InstanceName
                ModuleName        = $resource.ModuleName
                ModuleVersion     = $resource.ModuleVersion
                RebootRequested   = $resource.RebootRequested
                ResourceId        = $resource.ResourceId
                ResourceName      = $resource.ResourceName
                SourceInfo        = $resource.SourceInfo
                StartDate         = $dt
                DependsOn         = $resource.DependsOn -join ", "
                StateChanged      = $resource.StateChanged

            } # PSCustomObject

        } # ForEach Resourc

    } # ForEach

    return $data

} # Function