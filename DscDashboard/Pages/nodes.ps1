New-UDPage -Name "Nodes" -Icon desktop -Content {
    New-DscDashboardCustomHeader -Text "Nodes" -icon 'desktop'

    New-UDCard -Content {

        New-UDGrid -Title "" -Headers @(" ","NodeName","IP","Configurations","Resources","OS","Compliancy","Reboot","Last Contact") -Properties @("Icon","NodeLink","IP","NumConfigurations","NumberOfResources","OS","Compliancy","RebootRequested","StartTime") -Endpoint {

                $Cache:AllNodes | Out-UDGridData

        } -DefaultSortColumn NodeName -DateTimeFormat "LLLLL" -AutoRefresh #-ServerSideProcessing

    } # Card

} # Page