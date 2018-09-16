New-UDPage -Name "Reports" -Icon bar_chart -Content {

    New-DscDashboardCustomHeader -Text "Reports" -icon 'bar_chart'

    New-UDCard -Content {

        New-UDGrid -Title "" -Headers @(
        
            " ","JobId","OperationType","NodeName","IP","Configurations","Resources","Compliancy","Reboot","Last Contact"

        ) -Properties @(

            "Icon","JobLink","OperationType","NodeName","IP","NumConfigurations","NumberOfResources","Compliancy","RebootRequested","StartTime"
            
        ) -Endpoint {

                Get-DscDashboardReport | Out-UDGridData

        } -PageSize 25 -DefaultSortColumn StartTime -DefaultSortDescending -DateTimeFormat "LLLLL" -AutoRefresh -RefreshInterval (10*60)  #-ServerSideProcessing

    } # Card

} # Page