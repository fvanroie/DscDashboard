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


Function Get-ODBCData
{

    Param(

        [String]$Query = $(Throw 'Query is required.'),

        [AllowEmptyString()]
        [String]$ConnectionString,

        [AllowEmptyCollection()]
        [System.Data.Odbc.OdbcParameter[]]$SqlParameter

    )

    if (!$ConnectionString) {
        $ConnectionString = "DSN=DscDashboard; $env:DSC_SQL"
    }

    $conn = New-Object System.Data.Odbc.OdbcConnection
    $conn.ConnectionString = $ConnectionString

    try {
        $conn.open()
    }
    catch {
        Throw $_
    } # try

    if ($PSBoundParameters.ContainsKey('SqlParameter'))
    {

        # SQL Statement with parameters
        $cmd = $conn.CreateCommand();
        $cmd.CommandText = $Query

        $SqlParameter | ForEach-Object {
            $cmd.Parameters.Add($_) | Out-Null
        } # foreach

    }
    else
    {

        # SQL Statement without parameters
        $cmd = New-object System.Data.Odbc.OdbcCommand($Query, $conn)

    } # if

    $ds = New-Object system.Data.DataSet
    (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | Out-Null
    $conn.close()

    Return $ds.Tables[0]
}