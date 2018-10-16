New-UDPage -Name "Home" -Icon home -Content {

    New-DscDashboardCustomHeader -Text "Home" -icon 'home'

    New-UDRow {

        New-UDColumn -Size 12 {

            New-UDLayout -Columns 3 -Content {

                #region Node Compliancy
                    New-UDChart -Title "Node Compliancy" -Type Doughnut -RefreshInterval 60 -Endpoint {

                        $result = $Cache:AllNodes | Select-Object -ExpandProperty Compliancy | Group-Object -Property text | Sort-Object name


                        # Build the legend using appropriate colors
                        $colors = @()
                        $result | ForEach-Object {
                            switch ($_.Name) {
                                'Compliant' {
                                    $colors += 'green'
                                    break
                                }
                                'Not Compliant' {
                                    $colors += 'orange'
                                    break
                                }
                                'Error' {
                                    $colors += 'red'
                                    break
                                }
                                'No Contact' {
                                    $colors += 'gray'
                                    break
                                }
                            }
                        }

                        $result | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -DatasetLabel "Node Compliancy" -BackgroundColor $colors

                    } -Options $legendOptions #-Links $nodesLink

                #endregion

                #region Resource Compliancy
                New-UDChart -Title "Resource Compliancy" -Type Doughnut -RefreshInterval 60 -Endpoint {

                    $result = $Cache:AllNodes #| select -ExpandProperty Compliancy | Group-Object -Property text | Sort-Object name

                    # Build the legend using appropriate colors
                    $colors = @('green','orange')
                    $data = @(
                        [PSCustomObject]@{
                            'Name' = 'Compliant'
                            'Count' = 0
                        }
                        [PSCustomObject]@{
                            'Name' = 'Not Compliant'
                            'Count' = 0
                        }
                    )
                    $result | ForEach-Object {
                        $data[0].Count += $_.ResourcesInDesiredState
                        $data[1].Count += $_.ResourcesNotInDesiredState
                    }

                    $data | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -DatasetLabel "Resource Compliancy" -BackgroundColor $colors

                } -Options $legendOptions #-Links $nodesLink

            #endregion

                #region Reboot Requested
                    New-UDChart -Title "Reboot Requested" -Type Doughnut -RefreshInterval 60 -Endpoint {

                        $colors = @('green','red')

                        $result = $Cache:AllNodes | Select-Object -Property RebootRequested | Group-Object -Property RebootRequested | Select-Object count,name | Sort-Object name

                        #inverse colors if the first item is true
                        #if ($result[0].name) {
                        #    if ($result[0].name -eq $true) {
                        #        $colors = @('red','green')
                        #    }
                        #}

                        $result | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -DatasetLabel "Node Compliancy" -BackgroundColor $colors

                    } -Options $legendOptions #-Links $nodesLink
                #endregion

                #region OS Version
                    New-UDChart -Title "OS Version" -Type Doughnut -RefreshInterval 5 -Endpoint {

                        $colors = @('#BF9BCF','#0066CC','#F5E44C','#B2F2EC','#FDCCC6','#CCE0F4',"#D6B77C","#9FC9D4"   ,"#CCCCCC","#32389F")

                        $result = $Cache:AllNodes | Select-Object -Property OS | Group-Object -Property OS | Select-Object count,name | Sort-Object name
                        $result | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -DatasetLabel "Node Compliancy" -BackgroundColor $colors

                    } -Options $legendOptions #-Links $nodesLink
                #endregion

                #region PowerShell Version
                New-UDChart -Title "PowerShell Version" -Type Doughnut -RefreshInterval 60 -Endpoint {

                    $colors = @('#CCE0F4',"#D6B77C","#9FC9D4"   ,"#CCCCCC","#32389F", '#BF9BCF','#0066CC','#F5E44C','#B2F2EC','#FDCCC6')

                    $result = $Cache:AllNodes | Select-Object -Property PSVersion | Group-Object -Property PSVersion | Select-Object count,name | Sort-Object name
                    $result | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -DatasetLabel "Node Compliancy" -BackgroundColor $colors

                } -Options $legendOptions #-Links $nodesLink
                #endregion

                #region LCM Refresh Mode
                New-UDChart -Title "LCM Refresh Mode" -Type Doughnut -RefreshInterval 60 -Endpoint {

                    $colors = @('green','red')

                    $result = $Cache:AllNodes | Select-Object -Property Mode | Group-Object -Property Mode | Select-Object count,name | Sort-Object name

                    $result | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -DatasetLabel "Refresh Mode" -BackgroundColor $colors

                } -Options $legendOptions #-Links $nodesLink
            #endregion

            }

        }

    }
}