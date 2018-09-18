Function Get-DscDashboardNodeCompliancy
{

    Param(
        [String]$Status,

        [DateTime]$StartTime,

        [int]$RefreshFrequencyMins,

        [int]$ResourcesNotInDesiredState,

        [String]$Url
    )


    # Check if node has reported back in the last 2 days
    #try
    #{
    # Check for errors
    If ($Status -ne "Success")
    {
        $Compliancy = New-UDLink -Text "Error" -Url $Url -Icon remove -FontColor Red
        $Status = 'Error'

    }
    else
    {

        if ($StartTime -and 0 -lt $RefreshFrequencyMins -and $StartTime.AddMinutes(5 * $RefreshFrequencyMins) -lt (Get-Date))
        {
            $Compliancy = New-UDLink -Text "No Contact" -Url $Url -Icon chain_broken -FontColor Gray
            $Status = ""

        }
        else
        {

            # Check the number of resource in desired state
            if ($ResourcesNotInDesiredState -eq 0)
            {
                $Compliancy = New-UDLink -Text "Compliant" -Url $Url -Icon check -FontColor Green
                $Status = $_.Status

            }
            else
            {

                $Compliancy = New-UDLink -Text "Not Compliant" -Url $Url -Icon warning -FontColor Orange
                $Status = $_.Status

            } # Desired state

        } # Error

    } # Offline
    #}
    #Catch {
    #            $Compliancy = New-UDLink -Text "No Data" -Url $Url -Icon times -FontColor Blue
    #            $Status = "No Data"
    #}

    return $Compliancy, $Status

}