#requires -Version 3
<#
.DESCRIPTION
    Export custom query results from ConfigMgr database
.PARAMETER ServerName
    SQL Server hostname which supports the CM database
.PARAMETER SiteCode
    ConfigMgr Site Code
.PARAMETER InputType
    List: File, Folder, Select
.PARAMETER QueryFile
    SQL query statement file(s) having a .sql extension
.PARAMETER QueryFilePath
    Path to folder which contains .sql query files
    Default is the .\Queries folder within the module directory
.PARAMETER OutputType
    List: Pipeline, Csv, Excel, Grid
    Pipeline returns results to the powershell pipeline for serial processing
    Csv saves results to .CSV file(s)
    Excel saves results to .CSV files(s) and converts them to Excel .xlsx files
    Grid displays results using powershell gridview
.PARAMETER OutputPath
    Folder where .csv or .xlsx files will be saved
.NOTES
    1.0.0 - DS - Initial release
    1.0.1 - DS - Added Excel output option
    1.0.2 - DS - Fixed Excel "saveas" when existing found
.EXAMPLE
    Run-CmCustomQuery -ServerName 'cm01.contoso.local' -SiteCode 'P01'
.EXAMPLE
    Run-CmCustomQuery -ServerName 'cm01.contoso.local' -SiteCode 'P01' -InputType Folder -OutputType Csv -OutputPath "c:\reports"
.EXAMPLE
    Run-CmCustomQuery -ServerName 'cm01.contoso.local' -SiteCode 'P01' -QueryFile $qfiles -OutputType Excel -OutputPath "c:\reports"
#>

function Run-CmCustomQuery {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="Site Database Server Name")]
            [ValidateNotNullOrEmpty()]
            [string] $ServerName,
        [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
            [ValidateNotNullOrEmpty()]
            [string] $SiteCode,
        [parameter(Mandatory=$False, HelpMessage="Query Input Type")]
            [ValidateSet('Select','File','Folder')]
            [string] $InputType = 'Select',
        [parameter(Mandatory=$False, HelpMessage="Query File names when using Input type File")]
            [string] $QueryFile = "",
        [parameter(Mandatory=$False, HelpMessage="Path to Query files")]
            [string] $QueryFilePath = ".\queries\",
        [parameter(Mandatory=$False, HelpMessage="Output Type")]
            [ValidateSet('Pipeline','Csv','Excel','Grid')]
            [string] $OutputType = 'Pipeline',
        [parameter(Mandatory=$False, HelpMessage="Path for Output files when using Csv or Excel")]
            [string] $OutputPath = ".\reports\"
    )

    Write-Verbose "servername...... $ServerName"
    Write-Verbose "sitecode........ $SiteCode"

    if ([string]::IsNullOrEmpty($QueryFilePath)) {
        $QueryFilePath = $PWD
    }
    $OutputPath = $(Get-Item -Path $OutputPath).FullName
    Write-Verbose "inputType....... $InputType"
    Write-Verbose "outputType...... $OutputType"
    Write-Verbose "outputPath...... $OutputPath"
    Write-Verbose "queryFile....... $QueryFile"
    Write-Verbose "queryFilePath... $QueryFilePath"

    function ConvertTo-Excel {
        param (
            [parameter(Mandatory=$True)]
                [ValidateNotNullOrEmpty()]
                [string] $CsvFile,
            [parameter(Mandatory=$True)]
                [ValidateNotNullOrEmpty()]
                [string] $XlFile,
            [parameter(Mandatory=$False)]
                [string] $delimiter = ','
        )
        if (!(Test-Path $CsvFile)) {
            Write-Error "$CsvFile not found!"
            break
        }
        Write-Verbose "opening an instance of microsoft excel"
        $excel = New-Object -ComObject Excel.Application 
        Write-Verbose "adding workbook"
        $workbook  = $excel.Workbooks.Add(1)
        Write-Verbose "selectincg worksheet 1"
        $worksheet = $workbook.worksheets.Item(1)
        $TxtConnector = ("TEXT;" + $CsvFile)
        Write-Verbose "connector: $TxtConnector"
        $Connector = $worksheet.QueryTables.Add($TxtConnector,$worksheet.Range("A1"))
        $query = $worksheet.QueryTables.Item($Connector.name)
        $query.TextFileOtherDelimiter = $delimiter
        $query.TextFileParseType  = 1
        $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
        $query.AdjustColumnWidth = 1
        $query.Refresh()
        $query.Delete()
        Write-Verbose "saving content to $XlFile"
        try {
            if (Test-Path $XlFile) { Remove-Item -Path $XlFile -Force }
            $Workbook.SaveAs($XlFile,51) | Out-Null
            Write-Verbose "saved output successfully"
            $result = 0
        }
        catch {
            Write-Verbose "error: $($_.Exception.Message)"
            $result = -1
        }
        finally {
            $excel.Quit()
        }
        if ($excel) { 
            Get-Process -Name 'EXCEL' | Stop-Process -Confirm:$False
        }
        Write-Output $result
    }

    switch ($InputType) {
        'File' {
            if (!(Test-Path $QueryFile)) {
                if (!(Test-Path (Join-Path -Path $QueryFilePath -ChildPath $QueryFile))) {
                    Write-Warning "$QueryFile not found!"
                    $stop = $true
                }
                else {
                    $qfiles = @((Join-Path -Path $QueryFilePath -ChildPath $QueryFile))
                }
            }
            else {
                $qfiles = @($QueryFile)
            }
            break
        }
        'Folder' {
            if (!(Test-Path $QueryFilePath)) {
                $stop = $True
                break
            }
            else {
                $qfiles = Get-ChildItem -Path $QueryFilePath -Filter "*.sql" | Sort-Object Name
                Write-Verbose "$($qfiles.count) query files were found"
            }
            break
        }
        default {
            $qfiles = Get-ChildItem -Path $QueryFilePath -Filter "*.sql" | Sort-Object Name
            if ($qfiles.count -lt 1) {
                Write-Warning "$QueryFilePath contains no .sql files"
                break
            }
            Write-Verbose "$($qfiles.count) query files were found"
            if (('Csv','Excel') -contains $OutputType) {
                $qfiles = $qfiles | Select -ExpandProperty Name | Out-GridView -Title "Select Queries to Run" -OutputMode Multiple
            }
            else {
                $qfiles = $qfiles | Select -ExpandProperty Name | Out-GridView -Title "Select Query to Run" -OutputMode Single
            }
            if (!($qfiles.Count -gt 0)) {
                Write-Warning "No queries were selected"
                $stop = $True
            }
            else {
                Write-Verbose "$($qfiles.Count) queries were selected"
            }
            break
        }
    } # switch

    if ($stop) { break }

    Write-Verbose "opening database connection"
    $QueryTimeout = 120
    $ConnectionTimeout = 30
    #Action of connecting to the Database and executing the query and returning results if there were any.
    $conn = New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString = $ConnectionString
    try {
        $conn.Open()
        Write-Verbose "connection opened successfully"
    }
    catch {
        Write-Error $_.Exception.Message
        break
    }

    Write-Verbose "processing query files list"

    foreach ($qfile in $qfiles) {
        Write-Verbose "file: $qfile"
        $f = Get-Item -Path (Join-Path -Path $QueryFilePath -ChildPath $qfile)
        $QueryFile  = $f.FullName
        $QueryName  = $f.BaseName -replace '.sql',''
        $OutputFile = Join-Path -Path $OutputPath -ChildPath "$QueryName.csv"
        $ExcelFile  = $OutputFile -replace '.csv','.xlsx'
        Write-Verbose "query file...... $QueryFile"
        Write-Verbose "query name...... $QueryName"
        Write-Verbose "output file..... $OutputFile"
        Write-Verbose "excel file...... $ExcelFile"
        $qtext = Get-Content -Path $QueryFile
        if (![string]::IsNullOrEmpty($qtext)) {
            Write-Verbose "QUERY... $qtext"
            $cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
            $cmd.CommandTimeout = $QueryTimeout
            $ds = New-Object System.Data.DataSet
            $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            [void]$da.Fill($ds)
            $rowcount = $($ds.Tables).Rows.Count
            if ($rowcount -gt 0) {
                Write-Host "$rowcount rows returned" -ForegroundColor Green
                switch ($OutputType) {
                    'Pipeline' {
                        $($ds.Tables).Rows
                        break
                    }
                    'Csv' {
                        Write-Verbose "report file..... $OutputFile"
                        $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path $OutputFile
                        Write-Host "exported to: $csvfile" -ForegroundColor Green
                        break
                    }
                    'Excel' {
                        Write-Verbose "excel file...... $ExcelFile"
                        $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path $OutputFile
                        $exitcode = ConvertTo-Excel -CsvFile $OutputFile -XlFile $ExcelFile
                        Write-Verbose "exit code....... $exitcode"
                        Write-Host "exported to: $ExcelFile" -ForegroundColor Green
                        break
                    }
                    default {
                        Write-Verbose "grid view....... "
                        $($ds.Tables).Rows | Out-GridView -Title "Query Results: $QueryName"
                        break
                    }
                } # switch
            }
            else {

            }
        } # if
        else {
            Write-Warning "$QueryFile is empty"
        }
    } # foreach

    Write-Verbose "closing database connection"
    $conn.Close()

    Write-Verbose "done!"
}

Export-ModuleMember -Function Run-CmCustomQuery
